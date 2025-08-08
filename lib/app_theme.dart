import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF4C4DDC);
  static const Color secondaryColor = Color(0xFFEDEDFC);
  static const Color textColor = Color(0xFF0F0F0F);
  static const Color subtitleColor = Color(0xFF939393);
  static const Color inactiveIndicatorColor = Color(0xFFE0E0E3);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          color: textColor,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: TextStyle(
          color: subtitleColor,
          fontSize: 14,
          fontWeight: FontWeight.w300,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}