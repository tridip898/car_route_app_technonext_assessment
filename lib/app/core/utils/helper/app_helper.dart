import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class AppHelper {
  void hideLoader() {
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
  }

  void hideKeyboard() {
    FocusScopeNode currentFocus = FocusScope.of(Get.context!);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      currentFocus.focusedChild?.unfocus();
    }
  }

  showLoader({bool needToShow = true}) {
    if (needToShow) {
      if (!EasyLoading.isShow) {
        return EasyLoading.show(
          status: "Loading...",
          maskType: EasyLoadingMaskType.black,
          dismissOnTap: kDebugMode ? true : false,
        );
      }
    }
  }

  void setStatusBarBlack() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }
}
