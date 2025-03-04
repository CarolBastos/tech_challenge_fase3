import 'package:flutter/material.dart';

class AppColors {
  static const int _purplePrimaryValue = 0xFF9C27B0;
  static const MaterialColor primary =
      MaterialColor(_purplePrimaryValue, <int, Color>{
        50: Color(0xFFF3E5F5),
        100: Color(0xFFE1BEE7),
        200: Color(0xFFCE93D8),
        300: Color(0xFFBA68C8),
        400: Color(0xFFAB47BC),
        500: Color(_purplePrimaryValue),
        600: Color(0xFF8E24AA),
        700: Color(0xFF7B1FA2),
        800: Color(0xFF6A1B9A),
        900: Color(0xFF4A148C),
      });
  static const Color background = Colors.white;
  static const Color shadow = Colors.black12;
  static const Color error = Colors.red;
}
