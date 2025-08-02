import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../constants/app_colors.dart';
import '../constants/app_constraints.dart';
import '../constants/app_text_style.dart';

class DistanceDurationBottomSheet extends StatelessWidget {
  final double? distance;
  final double? duration;

  const DistanceDurationBottomSheet({super.key, this.distance, this.duration});

  @override
  Widget build(BuildContext context) {
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
                "Fastest route now due to traffic conditions",
                style: text12Style(color: AppColors.grey),
              ),
              gapH20,
            ],
          ),
        ),
      ),
    );
  }
}
