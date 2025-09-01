import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pharma_app/features/auth/models/user.dart';
import 'package:pharma_app/features/auth/presentation/state/auth_state/auth_state.dart';
import 'package:pharma_app/features/auth/services/auth_remote_service.dart';

// ⬇️ import للـ tokenProvider بتاع المنتجات
import 'package:pharma_app/features/product/providers/core_providers.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref; // ✅ علشان نحدّث tokenProvider
  final AuthRemoteService _authService;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AuthNotifier(this.ref, this._authService) : super(const AuthInitial()) {
    _bootstrap();
  }

  /// 🔍 Check if user already logged in
  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    final token = await _secureStorage.read(key: 'accessToken');

    if (userJson != null && token != null && token.isNotEmpty) {
      final user = User.fromJson(jsonDecode(userJson));
      // ✅ فعّل التوكن على مستوى التطبيق
      ref.read(tokenProvider.notifier).state = token;
      state = AuthAuthenticated(user, token);
    } else {
      // امسح أي توكن قديم
      ref.read(tokenProvider.notifier).state = '';
      state = const AuthUnauthenticated();
    }
  }

  /// 🔑 Login
  Future<void> login(String email, String password) async {
    state = const AuthLoading();
    try {
      final result = await _authService.login(email: email, password: password);
      final user = result['user'] as User;
      final token = result['token'] as String? ?? '';

      // ✅ Save user + token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(user.toJson()));
      await _secureStorage.write(key: 'accessToken', value: token);

      // ✅ فعّل التوكن للريبو/السيرفس
      ref.read(tokenProvider.notifier).state = token;

      state = AuthAuthenticated(user, token);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  /// 📝 Signup
  Future<void> register(
    String name,
    String email,
    String password,
    String confirmPassword,
  ) async {
    state = const AuthLoading();
    try {
      final result = await _authService.signup(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );

      final user = result['user'] as User;
      final token = result['token'] as String? ?? '';

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(user.toJson()));
      await _secureStorage.write(key: 'accessToken', value: token);

      ref.read(tokenProvider.notifier).state = token;

      state = AuthAuthenticated(user, token);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  /// 🔒 Forgot Password
  Future<void> forgotPassword(String email) async {
    state = const AuthLoading();
    try {
      await _authService.forgotPassword(email);
      state = const AuthForgotPasswordSent();
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  /// 🔑 Verify Reset Code
  Future<void> verifyResetCode(String resetCode) async {
    state = const AuthLoading();
    try {
      await _authService.verifyResetCode(resetCode);
      state = const AuthVerifyingResetCode();
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  /// 🔄 Reset Password
  Future<void> resetPassword(String email, String newPassword) async {
    state = const AuthLoading();
    try {
      final token = await _authService.resetPassword(
        email: email,
        newPassword: newPassword,
      );
      if (token != null && token.isNotEmpty) {
        await _secureStorage.write(key: 'accessToken', value: token);
        ref.read(tokenProvider.notifier).state = token; // ✅
      }
      state = const AuthResetPasswordSuccess();
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  /// 🚪 Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await _secureStorage.delete(key: 'accessToken');

    // ✅ امسح التوكن من الـ provider كمان
    ref.read(tokenProvider.notifier).state = '';

    state = const AuthUnauthenticated();
  }
}

/// Riverpod provider (inject service into notifier)
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  return AuthNotifier(ref, AuthRemoteService());
});
