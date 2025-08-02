import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart'
    as poly_line;
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constraints.dart';
import '../../core/utils/helper/location_service.dart';
import '../../core/widget/distance_duration_bottom_sheet.dart';

class MapScreenController extends GetxController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  PersistentBottomSheetController? sheetController;
  GoogleMapController? googleMapController;
  final Rxn<LatLng> origin = Rxn<LatLng>();
  final Rxn<LatLng> destination = Rxn<LatLng>();
  final markers = <Marker>{}.obs;
  final polylines = <Polyline>{}.obs;
  final poly_line.PolylinePoints polylinePoints = poly_line.PolylinePoints(
    apiKey: dotenv.env['GOOGLE_MAPS_API_KEY'] ?? "",
  );
  final initialCameraPosition = CameraPosition(
    target: LatLng(23.8041, 90.4152),
    zoom: 12,
  ).obs;

  // final googleMapKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
  final originAddress = "".obs, destinationAddress = "".obs;
  final routeDistance = 0.0.obs;
  final routeDuration = 0.0.obs;
  final showBottomSheet = false.obs;

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
    requestPermissionAndMoveToCurrentLocation();
    listenBottomSheet();
  }

  Future<void> requestPermissionAndMoveToCurrentLocation() async {
    try {
      final position = await LocationService().getValidLocation();
      if (position != null) {
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
    if (origin.value == null ||
        (origin.value != null && destination.value != null)) {
      origin.value = position;
      destination.value = null;
      polylines.clear();
      sheetController?.close();
      addMarker(position, "origin");

      originAddress.value = await getAddressFromLatLng(
        origin.value?.latitude ?? 0.0,
        origin.value?.longitude ?? 0.0,
      );
    } else {
      destination.value = position;
      addMarker(position, "destination");
      destinationAddress.value = await getAddressFromLatLng(
        destination.value?.latitude ?? 0.0,
        destination.value?.longitude ?? 0.0,
      );
      drawRoute();
    }
  }

  void addMarker(LatLng position, String markerId) {
    final marker = Marker(
      markerId: MarkerId(markerId),
      position: position,
      infoWindow: InfoWindow(title: markerId.capitalizeFirst),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        markerId == 'origin'
            ? BitmapDescriptor.hueGreen
            : BitmapDescriptor.hueRed,
      ),
    );

    if (markerId == 'origin') {
      markers.clear();
    }
    markers.add(marker);
  }

  Future<void> drawRoute() async {
    logger.i("drawRoute");
    if (origin.value == null || destination.value == null) return;

    poly_line.RoutesApiResponse result =
        await polylinePoints.getRouteBetweenCoordinatesV2(
      request: poly_line.RoutesApiRequest(
        origin: poly_line.PointLatLng(
          origin.value!.latitude,
          origin.value!.longitude,
        ),
        destination: poly_line.PointLatLng(
          destination.value!.latitude,
          destination.value!.longitude,
        ),
        travelMode: poly_line.TravelMode.driving,
        routingPreference: poly_line.RoutingPreference.trafficAware,
      ), // Efficient car route [cite: 9]
    );

    if (result.routes.isNotEmpty) {
      poly_line.Route route = result.routes.first;

      logger.i('Duration: ${route.durationMinutes} minutes');
      logger.i('Distance: ${route.distanceKm} km');

      final polyline = Polyline(
        polylineId: const PolylineId('route'),
        color: AppColors.primaryColor.withValues(alpha: .8),
        width: 4,
        points: (route.polylinePoints
                ?.map((p) => LatLng(p.latitude, p.longitude))
                .toList() ??
            []),
      );
      polylines.add(polyline);
      polylines.refresh();

      routeDistance.value = route.distanceKm ?? 0.0;
      routeDuration.value = route.durationMinutes ?? 0.0;
      showBottomSheet.value = true;
      logger.i("showBottomSheet ${showBottomSheet.value}");
    }
  }

  Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks[0];
        final address =
            "${(place.subLocality ?? "").isNotEmpty ? "${place.subLocality}, " : ""}${(place.locality ?? "").isNotEmpty ? "${place.locality}, " : ""}${place.country}";
        return address;
      } else {
        return "";
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  void clearMap() {
    markers.clear();
    polylines.clear();
    sheetController?.close();
    origin.value = null;
    destination.value = null;
  }
}
