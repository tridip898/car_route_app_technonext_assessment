import 'package:car_route_app_assessment_technonext/app/core/constants/app_assets.dart';
import 'package:car_route_app_assessment_technonext/app/core/constants/app_colors.dart';
import 'package:car_route_app_assessment_technonext/app/core/constants/app_constraints.dart';
import 'package:car_route_app_assessment_technonext/app/core/constants/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'map_screen_controller.dart';

class MapScreenView extends GetView<MapScreenController> {
  const MapScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.primaryColor,
        title: Text(
          'Car Route',
          style: text16Style(isWhiteColor: true),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Obx(() {
          return Stack(
            children: [
              SizedBox(
                height: Get.height,
                width: Get.width,
                child: GoogleMap(
                  initialCameraPosition: controller.initialCameraPosition,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  onMapCreated: (mapController) {
                    controller.googleMapController = mapController;
                  },
                  markers: controller.markers,
                  polylines: controller.polylines.toSet(),
                  onTap: (position) => controller.handleMapTap(position),
                ),
              ),
              if (controller.origin.value?.latitude != null &&
                  controller.destination.value?.latitude != null) ...[
                Positioned(
                  top: 20.h,
                  left: 20.w,
                  right: 20.w,
                  child: IntrinsicHeight(
                    child: Container(
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            spreadRadius: 4,
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      padding: mainPadding(12, 12),
                      child: originAndDestinationViewer(),
                    ),
                  ),
                )
              ],
            ],
          );
        }),
      ),
    );
  }

  Widget originAndDestinationViewer() {
    return Row(
      children: [
        Column(
          children: [
            Image.asset(
              currentLocationIcon,
              height: 16.w,
              color: AppColors.primaryColor,
            ),
            gapH3,
            Flexible(
              child: Container(
                width: 1,
                decoration: BoxDecoration(color: Colors.grey.withValues(alpha: .4)),
              ),
            ),
            gapH3,
            Image.asset(
              destinationIcon,
              height: 14.w,
              color: Colors.red,
            ),
          ],
        ),
        gapW12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.originAddress.value,
                style: text14Style(isPrimaryColor: true),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              appWidget.divider(height: 16),
              Text(
                controller.destinationAddress.value,
                style: text14Style(color: AppColors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
        ),
      ],
    );
  }
}
