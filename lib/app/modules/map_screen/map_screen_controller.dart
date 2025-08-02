import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constraints.dart';
import '../../core/services/geocoding_service.dart';
import '../../core/services/location_service.dart';
import '../../core/services/routing_service.dart';
import '../../core/widget/distance_duration_bottom_sheet.dart';

class MapScreenController extends GetxController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  PersistentBottomSheetController? sheetController;
  GoogleMapController? googleMapController;
  final locationService = LocationService();
  final geoCodingService = GeoCodingService();
  final routingService = RoutingService();
  final origin = Rxn<LatLng>(), destination = Rxn<LatLng>();
  final markers = <Marker>{}.obs, polylines = <Polyline>{}.obs;

  final initialCameraPosition = CameraPosition(
    target: LatLng(23.8041, 90.4152),
    zoom: 12,
  ).obs;

  final originAddress = "".obs, destinationAddress = "".obs;
  final routeDistance = 0.0.obs;
  final routeDuration = 0.0.obs;
  final showBottomSheet = false.obs, locationPermissionGranted = false.obs;

  @override
  void onInit() {
    logger.i(
      "dotenv.env['GOOGLE_MAPS_API_KEY'] ${dotenv.env['GOOGLE_MAPS_API_KEY']}",
    );

    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    logger.i("onReady");
    //When UI is ready and Map is Initialized it will request for permission and move to current location.
    requestPermissionAndMoveToCurrentLocation();
    //Listen BottomSheet
    listenBottomSheet();
  }

  Future<void> requestPermissionAndMoveToCurrentLocation() async {
    try {
      final position = await LocationService().getValidLocation();
      if (position != null) {
        locationPermissionGranted.value = true;
        //If permission is granted then move to current location.
        initialCameraPosition.value = CameraPosition(
          target: LatLng(position.latitude ?? 0, position.longitude ?? 0),
          zoom: 14,
        );
        googleMapController?.animateCamera(
          CameraUpdate.newCameraPosition(initialCameraPosition.value),
        );
      }
    } catch (e) {
      logger.e("Error fetching location: $e");
    }
  }

  void listenBottomSheet() {
    ever(showBottomSheet, (show) {
      if (show == true) {
        sheetController = scaffoldKey.currentState?.showBottomSheet(
          (context) => DistanceDurationBottomSheet(
            distance: routeDistance.value,
            duration: routeDuration.value,
          ),
          backgroundColor: AppColors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
        );

        sheetController?.closed.whenComplete(() {
          showBottomSheet.value = false;
        });
      }
    });
  }

  void handleMapTap(LatLng position) async {
    //For Handle Tap Origin Point and Destination Point
    //If origin point is null set position as origin and add marker. After that, if both point is selected and Users tap again set point as origin and clear destination point..
    //if origin point is not null set position as destination and add marker. Then draw route
    if (origin.value == null ||
        (origin.value != null && destination.value != null)) {
      origin.value = position;
      destination.value = null;
      polylines.clear();
      sheetController?.close();
      addMarker(position, originText);

      originAddress.value = await geoCodingService.getAddressFromLatLng(
        origin.value?.latitude ?? 0.0,
        origin.value?.longitude ?? 0.0,
      );
    } else {
      destination.value = position;
      addMarker(position, destinationText);
      destinationAddress.value = await geoCodingService.getAddressFromLatLng(
        destination.value?.latitude ?? 0.0,
        destination.value?.longitude ?? 0.0,
      );
      drawRoute();
    }
  }

  void addMarker(LatLng position, String markerId) {
    //Add marker in users selected position
    final marker = Marker(
      markerId: MarkerId(markerId),
      position: position,
      infoWindow: InfoWindow(title: markerId.capitalizeFirst),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        markerId == originText
            ? BitmapDescriptor.hueGreen
            : BitmapDescriptor.hueRed,
      ),
    );

    //if markerId is origin clears markers
    if (markerId == originText) {
      markers.clear();
    }
    markers.add(marker);
  }

  Future<void> drawRoute() async {
    logger.i("drawRoute");

    if (origin.value == null || destination.value == null) return;
    //Get route between origin and destination
    final result =
        await routingService.getRoute(origin.value!, destination.value!);
    if (result != null) {
      final polyline = Polyline(
        polylineId: const PolylineId('route'),
        color: AppColors.primaryColor.withValues(alpha: .8),
        width: 4,
        points: result.polylinePoints,
      );

      if (polyline.points.isEmpty) {
        appWidget.showSimpleToast(
          title: "Route Error",
          "Route data received but no path to draw.",
        );
        return;
      }

      polylines.add(polyline);
      polylines.refresh();

      //Move camera to fit markers
      moveCameraToFitMarkers();

      routeDistance.value = result.distanceKm;
      routeDuration.value = result.durationMin;
      showBottomSheet.value = true;
    } else {
      appWidget.showSimpleToast(
        title: "Route Not Found",
        "Could not find a route between selected points.",
      );
    }
  }

  void moveCameraToFitMarkers() {
    /// Moves the camera to fit both origin and destination markers within the visible map area.
    if (origin.value == null || destination.value == null) return;

    final southwest = LatLng(
      min(origin.value!.latitude, destination.value!.latitude),
      min(origin.value!.longitude, destination.value!.longitude),
    );

    final northeast = LatLng(
      max(origin.value!.latitude, destination.value!.latitude),
      max(origin.value!.longitude, destination.value!.longitude),
    );
    // Create a bounding box using southwest and northeast points
    final bounds = LatLngBounds(southwest: southwest, northeast: northeast);
    // Animate the camera to show the entire bounding box with some padding
    googleMapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 130),
    );
  }

  void clearMap() {
    //clear all value when refresh map
    markers.clear();
    polylines.clear();
    sheetController?.close();
    origin.value = null;
    destination.value = null;
    showBottomSheet.value = false;
    routeDistance.value = 0.0;
    routeDuration.value = 0.0;
  }

  void closeTopDialog() {
    originAddress.value = "";
    destinationAddress.value = "";
  }
}
