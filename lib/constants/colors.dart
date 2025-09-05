// lib/constants/colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Brand palette
  static const Color oceanDarkest = Color(0xFF0A1128);
  static const Color oceanDark    = Color(0xFF001F54);
  static const Color ocean        = Color(0xFF034078);
  static const Color oceanLight   = Color(0xFF1282A2);
  static const Color paleWhite    = Color(0xFFFEFCFB);

  // App usage
  static const Color primary       = oceanDark;     // buttons / accents
  static const Color primaryLight  = oceanLight;    // hovers / subtle accents
  static const Color background    = paleWhite;     // app background
  static const Color text          = oceanDarkest;  // main text
  static const Color subtitle      = Colors.black54;
  static const Color border        = Colors.black12;
  static const Color white         = Colors.white;
  static const Color shadow        = Colors.black12;

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error   = Color(0xFFF44336);

  // Neutrals
  static const Color textGray  = Color(0xFF9E9E9E);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color darkGray  = Color(0xFF616161);
}
