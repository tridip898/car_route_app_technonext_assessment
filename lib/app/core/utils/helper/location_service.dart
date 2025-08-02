import 'package:car_route_app_assessment_technonext/app/core/constants/app_constraints.dart';
import 'package:location/location.dart';

class LocationService {
  final Location location = Location();

  Future<LocationData?> getValidLocation() async {
    PermissionStatus permission = await location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await location.requestPermission();
    }
    logger.i(permission);
    if (permission != PermissionStatus.granted) {
      return null;
    }

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
    }

    if (!serviceEnabled) {
      return null;
    }

    try {
      return await location.getLocation();
    } catch (_) {
      return null;
    }
  }
}
