import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../constants/app_assets.dart';
import '../constants/app_colors.dart';
import '../constants/app_constraints.dart';
import '../constants/app_text_style.dart';
import '../utils/helper/app_helper.dart';
import 'dynamic_rich_text.dart';

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
    isErrorMessageBangla = false,
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
              child: Text(
                buttonText == "Try Again"
                    ? (isErrorMessageBangla ? "আবার চেষ্টা করুন" : buttonText)
                    : buttonText,
              ),
              onPressed: () {
                Navigator.pop(context);
                if (buttonText != "Ok") {
                  if (buttonText != "ঠিক আছে") {
                    try {
                      retryClick();
                      AppHelper().showLoader();
                    } catch (e) {
                      AppHelper().hideLoader();
                    }
                  }
                }
              })
        ],
      ),
    );
  }

  showSimpleToast(
    String? message, {
    String? title,
    bool isSuccess = false,
    bool doNeedScreenUtil = false,
    bool isInfo = false,
    bool isErrorMessageBangla = false,
    bool isError = true,
    int duration = 1000,
  }) {
    Get.snackbar(
      title ??
          (isSuccess
              ? isErrorMessageBangla
                  ? "সফল হয়েছে"
                  : "Success"
              : isInfo
                  ? isErrorMessageBangla
                      ? "তথ্য"
                      : "Info"
                  : isErrorMessageBangla
                      ? "ত্রুটি"
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



  Future<DateTime?> datePickerMain(
      {bool canPickFutureDate = true,
      bool canPickFirstDate = false,
      required DateTime initialDate,
      DateTime? firstDate}) async {
    DateTime? pickedDate = await showDatePicker(
      context: Get.context!,
      initialDate: canPickFirstDate
          ? (initialDate.isBefore(firstDate ?? DateTime.now())
              ? firstDate
              : initialDate)
          : initialDate,
      firstDate: canPickFirstDate
          ? (firstDate ?? DateTime.now())
          : DateTime.now().subtract(const Duration(days: 365)),
      lastDate: canPickFutureDate
          ? DateTime.now().add(const Duration(days: 365))
          : DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.purple, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red, // button text color
              ),
            ),
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(20.0), // Set the border radius here
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      initialDate = pickedDate;
      return initialDate;
      /*  logger.i("Before format $pickedDate");
      String formattedDate = DateFormat('dd MMM yyyy').format(pickedDate);
      logger.i("After format $formattedDate");
      return formattedDate;*/
    }
    return null;
  }


}
