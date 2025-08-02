import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const int _primaryColorValue = 0xFF00368F;
  static const MaterialColor colorPrimarySwatch = MaterialColor(
    _primaryColorValue,
    <int, Color>{
      50: Color(0xFFE0E7F3),
      100: Color(0xFFB3C3E1),
      200: Color(0xFF809CCC),
      300: Color(0xFF4D75B7),
      400: Color(0xFF2659A6),
      500: Color(_primaryColorValue),
      600: Color(0xFF003181),
      700: Color(0xFF002A70),
      800: Color(0xFF00235F),
      900: Color(0xFF001642),
    },
  );

  static const primaryColor = Color(0xFF00368F);
  static const dividerColor = Color(0xFFE7E7E7);

  static const Color grey = Color(0XFFF6E7D91);

  static const Color white = Color(0xFFFFFFFF);

  // static const Color likeWhite = Color(0xffFAFAFA);

  static const Color black = Color(0xff040405);

  static const inputColor = Color(0x8052596E);

  static const infoColor = Color(0xFF33b5e5);
  static const successColor = Color(0xFF00C851);
  static const errorColor = Color(0xFFff4444);
}
