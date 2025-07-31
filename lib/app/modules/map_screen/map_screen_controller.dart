import 'package:car_route_app_assessment_technonext/app/core/constants/app_colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/constants/app_constraints.dart';

class MapScreenController extends GetxController {
  final Rxn<LatLng> origin = Rxn<LatLng>();
  final Rxn<LatLng> destination = Rxn<LatLng>();

  final markers = <Marker>{}.obs;
  final polylines = <Polyline>{}.obs;

  GoogleMapController? googleMapController;
  final PolylinePoints polylinePoints = PolylinePoints(
    apiKey: dotenv.env['GOOGLE_MAPS_API_KEY'] ?? "",
  );
  final initialCameraPosition = CameraPosition(
    target: LatLng(23.8041, 90.4152),
    zoom: 12,
  );
  final googleMapKey = dotenv.env['GOOGLE_MAPS_API_KEY'];

  @override
  void onInit() {
    logger.i(
      "dotenv.env['GOOGLE_MAPS_API_KEY'] ${dotenv.env['GOOGLE_MAPS_API_KEY']}",
    );
    super.onInit();
  }

  void handleMapTap(LatLng position) {
    if (origin.value == null ||
        (origin.value != null && destination.value != null)) {
      // Set origin point
      origin.value = position;
      destination.value = null; // Reset destination
      polylines.clear();
      addMarker(position, "origin");
    } else {
      // Set destination point
      destination.value = position;
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
      // Clear all markers when a new origin is set
      markers.clear();
    }
    markers.add(marker);
  }

  Future<void> drawRoute() async {
    if (origin.value == null || destination.value == null) return;

    RoutesApiResponse result = await polylinePoints
        .getRouteBetweenCoordinatesV2(
          request: RoutesApiRequest(
            origin: PointLatLng(
              origin.value!.latitude,
              origin.value!.longitude,
            ),
            destination: PointLatLng(
              destination.value!.latitude,
              destination.value!.longitude,
            ),
            travelMode: TravelMode.driving,
            routingPreference: RoutingPreference.trafficAware,
          ), // Efficient car route [cite: 9]
        );

    if (result.routes.isNotEmpty) {
      Route route = result.routes.first;

      // Access route information
      logger.i('Duration: ${route.durationMinutes} minutes');
      logger.i('Distance: ${route.distanceKm} km');

      final polyline = Polyline(
        polylineId: const PolylineId('route'),
        color: AppColors.primaryColor,
        width: 6,
        points:
            (route.polylinePoints
                ?.map((p) => LatLng(p.latitude, p.longitude))
                .toList() ??
            []),
      );
      polylines.add(polyline);
    }
  }

  void clearMap() {
    markers.clear();
    polylines.clear();
    origin.value = null;
    destination.value = null;
  }
}
