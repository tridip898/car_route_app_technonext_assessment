import 'package:car_route_app_assessment_technonext/app/core/constants/app_constraints.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart'
    as poly_line;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RoutingService {
  final poly_line.PolylinePoints polylinePoints = poly_line.PolylinePoints(
    apiKey: dotenv.env['GOOGLE_MAPS_API_KEY'] ?? "",
  );

  Future<
      ({
        List<LatLng> polylinePoints,
        double distanceKm,
        double durationMin
      })?> getRoute(LatLng origin, LatLng destination) async {
    try {
      // Make a request to routes API to get the route between origin and destination
      final result = await polylinePoints.getRouteBetweenCoordinatesV2(
        request: poly_line.RoutesApiRequest(
          origin: poly_line.PointLatLng(origin.latitude, origin.longitude),
          destination: poly_line.PointLatLng(
              destination.latitude, destination.longitude),
          travelMode: poly_line.TravelMode.driving,
          routingPreference: poly_line.RoutingPreference.trafficAware,
        ),
      );

      if (result.routes.isEmpty) {
        appWidget.showSimpleToast(
          title: "Route Not Found",
          "Could not find a route between selected points.",
        );
        return null;
      }

      final route = result.routes.first;
      // Convert polyline points from response into a list of LatLng
      //polylinePoints means decoded polylines point for the entire route
      final points = route.polylinePoints
              ?.map((p) => LatLng(p.latitude, p.longitude))
              .toList() ??
          [];

      return (
        polylinePoints: points,
        distanceKm: route.distanceKm ?? 0.0,
        durationMin: route.durationMinutes ?? 0.0
      );
    } catch (e) {
      logger.e("Error in RoutingService: $e");
      return null;
    }
  }
}
