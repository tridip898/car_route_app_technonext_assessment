import 'package:car_route_app_assessment_technonext/app/core/constants/app_colors.dart';
import 'package:car_route_app_assessment_technonext/app/core/constants/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart'
    as poly_line;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/constants/app_constraints.dart';

class MapScreenController extends GetxController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  PersistentBottomSheetController? sheetController;
  final Rxn<LatLng> origin = Rxn<LatLng>();
  final Rxn<LatLng> destination = Rxn<LatLng>();

  final markers = <Marker>{}.obs;
  final polylines = <Polyline>{}.obs;

  GoogleMapController? googleMapController;
  final poly_line.PolylinePoints polylinePoints = poly_line.PolylinePoints(
    apiKey: dotenv.env['GOOGLE_MAPS_API_KEY'] ?? "",
  );
  final initialCameraPosition = CameraPosition(
    target: LatLng(23.8041, 90.4152),
    zoom: 12,
  );
  final googleMapKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
  final originAddress = "".obs, destinationAddress = "".obs;

  @override
  void onInit() {
    logger.i(
      "dotenv.env['GOOGLE_MAPS_API_KEY'] ${dotenv.env['GOOGLE_MAPS_API_KEY']}",
    );
    super.onInit();
  }

  void handleMapTap(LatLng position) async {
    if (origin.value == null ||
        (origin.value != null && destination.value != null)) {
      // Set origin point
      origin.value = position;
      destination.value = null; // Reset destination
      polylines.clear();
      sheetController?.close();
      originAddress.value = await getAddressFromLatLng(
          origin.value?.latitude ?? 0.0, origin.value?.longitude ?? 0.0);
      addMarker(position, "origin");
    } else {
      // Set destination point
      destination.value = position;
      destinationAddress.value = await getAddressFromLatLng(
          destination.value?.latitude ?? 0.0,
          destination.value?.longitude ?? 0.0);
      addMarker(position, "destination");
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
        color: AppColors.primaryColor,
        width: 6,
        points: (route.polylinePoints
                ?.map((p) => LatLng(p.latitude, p.longitude))
                .toList() ??
            []),
      );
      polylines.add(polyline);
      showDistanceAndDurationDialog(
        distance: route.distanceKm,
        duration: route.durationMinutes,
      );
    }
  }

  void clearMap() {
    markers.clear();
    polylines.clear();
    origin.value = null;
    destination.value = null;
  }

  Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks[0];
        final address =
            "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
        return address;
      } else {
        return "";
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  void showDistanceAndDurationDialog({double? distance, double? duration}) {
    final maxHeight = MediaQuery.of(Get.context!).size.height -
        kToolbarHeight -
        MediaQuery.of(Get.context!).padding.top -
        64.h;
    sheetController = scaffoldKey.currentState?.showBottomSheet(
      constraints: BoxConstraints(maxHeight: maxHeight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      (context) {
        return IntrinsicHeight(
          child: Container(
            width: Get.width,
            padding: mainPadding(20, 10),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      height: 4.h,
                      width: 36.w,
                      decoration: BoxDecoration(
                        color: AppColors.grey.withValues(alpha: .5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  gapH20,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          "Car Route",
                          style: text18Style(isWeight400: true),
                        ),
                      ),
                      gapW12,
                      Align(
                        alignment: Alignment.topRight,
                        child: Material(
                          shape: CircleBorder(),
                          clipBehavior: Clip.hardEdge,
                          color: AppColors.grey.withValues(alpha: .2),
                          child: InkWell(
                            onTap: Get.back,
                            child: Padding(
                              padding: mainPadding(4, 4),
                              child: Icon(Icons.close, size: 20.w),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  appWidget.divider(height: 20),
                  RichText(
                    text: TextSpan(
                      text: "${duration?.toStringAsFixed(0)} min",
                      style: text18Style(
                        color: Colors.red,
                        isWeight400: true,
                      ),
                      children: [
                        TextSpan(
                          text: " (${distance?.toStringAsFixed(1)} km)",
                          style: text18Style(
                            isWeight400: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  gapH8,
                  Text(
                    "Fastest Route now due to traffic conditions",
                    style: text12Style(),
                  ),
                  gapH20,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
