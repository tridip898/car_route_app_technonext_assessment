import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../constants/app_colors.dart';
import '../utils/helper/app_helper.dart';

class AppWidgets {
  final bool needScreenUtil = true;

  Widget gapH(double height) {
    return SizedBox(
      height: needScreenUtil ? height.h : height,
    );
  }

  Widget gapW(double width) {
    return SizedBox(
      width: needScreenUtil ? width.w : width,
    );
  }

  Widget divider({
    double height = 10,
    Color color = AppColors.dividerColor,
    double thickness = 1,
  }) {
    return Divider(
      color: color,
      height: needScreenUtil ? height.h : height,
      thickness: thickness,
    );
  }

  showSimpleDialog(
    String title,
    String body,
    retryClick, {
    buttonText = "Try Again",
    barrierDismissible = true,
  }) {
    if (Get.context == null) {
      return null;
    }
    return showDialog(
      context: Get.context!,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          // style: textAppBarStyle(),
        ),
        content: Text(
          body,
          // style: textRegularStyle(),
        ),
        actions: <Widget>[
          TextButton(
              child: Text(buttonText),
              onPressed: () {
                Navigator.pop(context);
                if (buttonText != "Ok") {
                  try {
                    retryClick();
                    AppHelper().showLoader();
                  } catch (e) {
                    AppHelper().hideLoader();
                  }
                }
              })
        ],
      ),
    );
  }

  void showSimpleToast(
    String? message, {
    String? title,
    bool isSuccess = false,
    bool doNeedScreenUtil = false,
    bool isInfo = false,
    bool isError = true,
    int duration = 1000,
  }) {
    Get.snackbar(
      title ??
          (isSuccess
              ? "Success"
              : isInfo
                  ? "Info"
                  : "Error"),
      message ?? "",
      icon: Icon(
        (isSuccess
            ? Icons.check_circle
            : isInfo
                ? Icons.info
                : Icons.error),
        color: AppColors.white,
      ),
      shouldIconPulse: true,
      barBlur: 20,
      overlayBlur: 1,
      isDismissible: true,
      snackPosition: SnackPosition.TOP,
      backgroundColor: (isSuccess
          ? AppColors.successColor.withValues(alpha: .8)
          : isInfo
              ? AppColors.infoColor.withValues(alpha: .8)
              : AppColors.errorColor.withValues(alpha: .8)),
      margin: EdgeInsets.only(
        top: doNeedScreenUtil ? 20.h : 20,
        left: doNeedScreenUtil ? 20.w : 20,
        right: doNeedScreenUtil ? 20.w : 20,
      ),
      colorText: AppColors.white,
      duration: Duration(milliseconds: duration),
    );
  }
}
