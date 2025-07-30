import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../constants/app_constraints.dart';

class AppHelper {
  final storage = const FlutterSecureStorage();
  late SharedPreferences prefs;

  saveToken(String token) async {
    await storage
        .write(key: "token", value: token)
        .whenComplete(() => logger.d('saveToken:  Saved'));
  }

  Future<String?> getToken() async {
    try {
      final accessToken = await storage.read(key: "token");
      return accessToken;
    } on PlatformException {
      await storage.deleteAll();
    }
    return null;
  }

  deleteToken() async {
    logger.i("Deleted");
    await storage.delete(key: "token");
    appHelper.hideLoader();
  }

  saveRefreshToken(String token) async {
    await storage
        .write(key: "refresh_token", value: token)
        .whenComplete(() => logger.d('saveToken:  Saved'));
  }

  Future<String?> getRefreshToken() async {
    try {
      final accessToken = await storage.read(key: "refresh_token");
      return accessToken;
    } on PlatformException {
      await storage.deleteAll();
    }
    return null;
  }

  deleteRefreshToken() async {
    logger.i("Deleted");
    await storage.delete(key: "refresh_token");
    appHelper.hideLoader();
  }

  saveIntPref(String key, int value) async {
    prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  deleteIntPref(String key) async {
    prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  Future<int?> getIntPref(String key) async {
    prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  saveStringPref(String key, String value) async {
    prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  deleteStringPref(String key) async {
    prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  Future<String?> getStringPref(String key) async {
    prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

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

  showLoader({needToShow = true}) {
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

  validateImageURL(String url) {
    String finalUrl = url;
    /* if (url.startsWith("upload")) {
      finalUrl = baseImageUrl + url;
    } else if (url.startsWith("/storage")) {
      finalUrl = baseImageUrl + url;
    } else if (url.contains("https:")) {
      finalUrl = url;
    } else if (!url.contains("/")) {
      finalUrl = baseImageUrl + url;
    } else if (url.startsWith("https")) {
      finalUrl = url;
    } else {
      finalUrl = baseImageUrl + url;
    }*/
    logger.i("Image url $finalUrl");
    return finalUrl;
  }

  void directionClick({String? lat, String? lng, String? shortUrl}) {
    if (Platform.isAndroid) {
      if ((shortUrl ?? "") != "") {
        launchUrlString(shortUrl ?? "");
      } else {
        launchUrlString(
          'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
        );
      }
    } else if (Platform.isIOS) {
      if ((shortUrl ?? "") != "") {
        launchUrlString(shortUrl ?? "");
      } else {
        launchUrlString('https://maps.apple.com/?q=$lat,$lng');
      }
    }
  }

  Future<void> launchPhoneDialer(String contactNumber) async {
    logger.i("Email launch $contactNumber");
    final Uri phoneUri = Uri(scheme: "tel", path: contactNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
      }
    } catch (error) {
      throw ("Cannot dial $phoneUri");
    }
  }

  launchEmail(String emailText) async {
    final uri = Uri.parse("mailto:$emailText");

    try {
      await launchUrl(uri);
    } catch (error) {
      throw ("Cannot send email to $uri");
    }
  }

  void setStatusBarWhite() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
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
