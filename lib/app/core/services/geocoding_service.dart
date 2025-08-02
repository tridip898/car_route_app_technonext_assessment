import 'package:geocoding/geocoding.dart';

class GeoCodingService {
  ///Extract readable address from LatLng by reverse geocoding
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
}
