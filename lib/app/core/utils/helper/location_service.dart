import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:location/location.dart' as lc;

import '../../../routes/app_pages.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constraints.dart';

class LocationService {
  static final RxBool isDialogOpen = false.obs;

  Future<Position?> getValidLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    logger.i("LocationPermission 1 ${permission.name}");

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        logger.i("LocationPermission.deniedForever");
        showPermissionDenyForeverDialog(() async {
          Get.back();
          Geolocator.openAppSettings();
        });
        return null;
      } else if (permission == LocationPermission.denied) {
        logger.i("LocationPermission.denied");
        showPermissionDenyDialog(
          () async {
            Get.back();
            getValidLocation();
          },
        );
        return null;
      }
    } else {
      if (Platform.isIOS) {
        if (permission == LocationPermission.deniedForever) {
          showPermissionDenyForeverDialog(() async {
            Get.back();
            Geolocator.openAppSettings();
          });
          return null;
        }
      }
    }
    logger.i("permissionStatus ${permission.name}");

    final location = lc.Location();
    bool isGpsEnabled = await location.serviceEnabled();
    if (!isGpsEnabled) {
      isGpsEnabled = await location.requestService();
      if (!isGpsEnabled) {
        showGpsDisabledDialog();
        return null;
      }
    }

    try {
      final LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );

      return await Geolocator.getCurrentPosition(
          locationSettings: locationSettings);
    } catch (e) {
      debugPrint("Location error: $e");
      showErrorDialog();
      return null;
    }
  }

  Future<Position?> getValidLocationInState() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.deniedForever) {
      logger.i("LocationPermission.deniedForever");
      showPermissionDenyForeverDialog(() async {
        Get.back();
        Geolocator.openAppSettings();
      });
      return null;
    } else if (permission == LocationPermission.denied) {
      logger.i("LocationPermission.denied");
      showPermissionDenyDialog(
        () async {
          Get.back();
          getValidLocation();
        },
      );
      return null;
    }
    logger.i("permissionStatus ${permission.name}");

    final location = lc.Location();
    bool isGpsEnabled = await location.serviceEnabled();
    if (!isGpsEnabled) {
      isGpsEnabled = await location.requestService();
      if (!isGpsEnabled) {
        showGpsDisabledDialog();
        return null;
      }
    }

    try {
      final LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );

      return await Geolocator.getCurrentPosition(
          locationSettings: locationSettings);
    } catch (e) {
      debugPrint("Location error: $e");
      showErrorDialog();
      return null;
    }
  }

  void showPermissionDenyDialog(void Function()? retryClick) {
    if (!isDialogOpen.value) {
      isDialogOpen.value = true;
      showDialog(
        context: Get.context!,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Permission Required'),
          backgroundColor: AppColors.white,
          content: const Text(
              'Location access is needed to find nearby Suzuki dealers. Please allow permission to use this feature. '),
          actions: [
            TextButton(
              onPressed: () {
                isDialogOpen.value = false;
                Get.back();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                isDialogOpen.value = false;
                retryClick?.call();
              },
              child: const Text("Grant Permission"),
            ),
          ],
        ),
      ).then((_) {
        isDialogOpen.value = false;
      });
    }
  }

  void showPermissionDenyForeverDialog(void Function()? retryClick) {
    if (!isDialogOpen.value) {
      isDialogOpen.value = true;
      showDialog(
        context: Get.context!,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text("Permission Denied Forever"),
          backgroundColor: AppColors.white,
          content: const Text(
              'Location services are disabled. Enable them in your device settings to locate the nearest dealer.'),
          actions: [
            TextButton(
              onPressed: () {
                isDialogOpen.value = false;
                Get.back();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                isDialogOpen.value = false;
                retryClick?.call();
              },
              child: const Text("Open Setting"),
            ),
          ],
        ),
      ).then((_) {
        isDialogOpen.value = false;
      });
    }
  }

  void showGpsDisabledDialog() {
    if (!isDialogOpen.value) {
      isDialogOpen.value = true;
      showDialog(
        context: Get.context!,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('GPS Disabled'),
          backgroundColor: AppColors.white,
          content: const Text(
              'GPS is turned off. Please enable GPS to detect your location and show nearby dealers.'),
          actions: [
            TextButton(
              onPressed: () {
                // checkAndEnableGps();
                isDialogOpen.value = false;
                Get.back();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ).then((_) {
        isDialogOpen.value = false;
      });
    }
  }

  void showErrorDialog() {
    if (!isDialogOpen.value) {
      isDialogOpen.value = true;
      showDialog(
        context: Get.context!,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          backgroundColor: AppColors.white,
          content: const Text(
              'We couldn’t retrieve your location. Please try again later'),
          actions: [
            TextButton(
              onPressed: () {
                isDialogOpen.value = false;
                Get.back();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ).then((_) {
        isDialogOpen.value = false;
      });
    }
  }
}
