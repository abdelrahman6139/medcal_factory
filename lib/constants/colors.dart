import 'package:flutter/material.dart';

class AppColors {
  // 🎨 Deep Ocean Blue Palette
  static const Color oceanDarkest = Color(0xFF0A1128);
  static const Color oceanDark = Color(0xFF001F54);
  static const Color ocean = Color(0xFF034078);
  static const Color oceanLight = Color(0xFF1282A2);
  static const Color paleWhite = Color(0xFFFEFCFB);

  // ✅ الاستخدام الأساسي في التطبيق
  static const Color primary = oceanDark; // Primary buttons
  static const Color background = paleWhite; // خلفية عامة
  static const Color text = oceanDarkest; // النص الأساسي
  static const Color subtitle = Colors.black54;
  static const Color border = Colors.black12;
  static const Color white = Colors.white;
  static const Color danger = Colors.red;
  static const Color shadow = Colors.black12;
  static const Color textGray = Color(0xFF9E9E9E);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color primaryLight = oceanLight;
  static const Color success = Color(0xFF4CAF50); // أخضر للتأكيد
  static const Color warning = Color(0xFFFFC107); // أصفر للتنبيه
  static const Color error = Color(0xFFF44336); // أحمر للأخطاء
}
