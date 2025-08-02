import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constraints.dart';
import '../../core/constants/app_text_style.dart';
import '../../core/widget/app_appbar.dart';
import 'map_screen_controller.dart';

class MapScreenView extends GetView<MapScreenController> {
  const MapScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      appBar: AppAppbar(
        refreshClick: controller.clearMap,
      ),
      body: SafeArea(
        child: Obx(() {
          return Stack(
            children: [
              //This widget will visualize map. Here used sized box for full screen.
              SizedBox(
                height: Get.height,
                width: Get.width,
                child: GoogleMap(
                  initialCameraPosition: controller.initialCameraPosition.value,
                  myLocationEnabled: controller.locationPermissionGranted.value,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  onMapCreated: (mapController) {
                    controller.googleMapController = mapController;
                    logger.i("Map is ready");
                  },
                  markers: controller.markers,
                  polylines: controller.polylines.toSet(),
                  onTap: (position) => controller.handleMapTap(position),
                ),
              ),
              //This will show origin and destination address on top of map like dialog
              if (controller.originAddress.value.isNotEmpty &&
                  controller.destinationAddress.value.isNotEmpty) ...[
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
              "assets/png/current_location.png",
              height: 16.w,
              color: AppColors.primaryColor,
            ),
            gapH3,
            Flexible(
              child: Container(
                width: 1,
                decoration:
                    BoxDecoration(color: Colors.grey.withValues(alpha: .4)),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      controller.originAddress.value,
                      style: text14Style(isPrimaryColor: true),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  gapW12,
                  Material(
                    shape: CircleBorder(),
                    clipBehavior: Clip.hardEdge,
                    color: AppColors.grey.withValues(alpha: .2),
                    child: InkWell(
                      onTap: controller.closeTopDialog,
                      child: Padding(
                        padding: mainPadding(4, 4),
                        child: Icon(Icons.close, size: 16.w),
                      ),
                    ),
                  )
                ],
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

  Widget showDistanceAndDurationDialog({double? distance, double? duration}) {
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
  }
}
