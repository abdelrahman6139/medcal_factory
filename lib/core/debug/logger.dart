// lib/core/debug/logger.dart
import 'dart:convert';

class L {
  /// فعّل/عطّل اللوجات بسهولة
  static bool enabled = true;

  /// Log Debug
  /// مثال نداء:
  /// L.d('HTTP →', 'GET /products', data: {'limit': 20});
  static void d(String tag, String message, {Map<String, dynamic>? data}) {
    if (!enabled) return;
    final ts = DateTime.now().toIso8601String();
    // ignore: avoid_print
    print('[$ts][$tag] $message');
    if (data != null) {
      final pretty = const JsonEncoder.withIndent('  ').convert(data);
      // ignore: avoid_print
      print(pretty);
    }
  }

  /// Log Error
  static void e(
    String tag,
    String message, {
    Object? error,
    StackTrace? st,
    Map<String, dynamic>? data,
  }) {
    if (!enabled) return;
    final ts = DateTime.now().toIso8601String();
    // ignore: avoid_print
    print('[$ts][$tag][ERROR] $message');
    if (error != null) {
      // ignore: avoid_print
      print('Error: $error');
    }
    if (st != null) {
      // ignore: avoid_print
      print(st);
    }
    if (data != null) {
      final pretty = const JsonEncoder.withIndent('  ').convert(data);
      // ignore: avoid_print
      print(pretty);
    }
  }
}
