// lib/features/product/providers/core_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// غيّر ده لو بتبني بالـ emulator/جهاز حقيقي
final baseUrlProvider = Provider<String>((ref) {
  return 'http://10.0.2.2:5000';
});

/// للتبسيط: توكن كنصيّة. بعد تسجيل الدخول حدّثه بـ stateProvider
final tokenProvider = StateProvider<String>((ref) {
  // مبدئيًا فاضي. بعد اللوجين اعمل: ref.read(tokenProvider.notifier).state = token;
  return '';
});
