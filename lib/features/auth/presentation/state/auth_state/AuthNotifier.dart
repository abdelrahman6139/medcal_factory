// lib/features/auth/presentation/state/auth_state/AuthNotifier.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pharma_app/features/auth/models/user.dart';
import 'package:pharma_app/features/auth/presentation/state/auth_state/AuthState.dart';
import 'package:pharma_app/features/auth/services/auth_remote_service.dart';

/// Riverpod provider (inject service into notifier)
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(AuthRemoteService());
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRemoteService _authService;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AuthNotifier(this._authService) : super(const AuthInitial()) {
    _checkAuthStatus();
  }

  // ------------------------------------------------------------
  // Session bootstrap
  // ------------------------------------------------------------
  Future<void> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    final token = await _secureStorage.read(key: 'accessToken');

    if (userJson != null && token != null && token.isNotEmpty) {
      final user = User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
      state = AuthAuthenticated(user);
    } else {
      state = const AuthUnauthenticated();
    }
  }

  // ------------------------------------------------------------
  // Login (NOW uses NAMED parameters to match your UI call)
  // ------------------------------------------------------------
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();
    try {
      final result = await _authService.login(email: email, password: password);

      // result['user'] can be a Map or already a User depending on service
      final dynamic userField = result['user'];
      final User user = switch (userField) {
        User u => u,
        Map<String, dynamic> m => User.fromJson(m),
        _ => throw Exception('Invalid user payload from API'),
      };

      final String? token = result['token'] as String?;

      // save user + token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(user.toJson()));
      if (token != null && token.isNotEmpty) {
        await _secureStorage.write(key: 'accessToken', value: token);
      }

      state = AuthAuthenticated(user);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  // ------------------------------------------------------------
  // Signup (also switched to NAMED parameters to match your screens)
  // ------------------------------------------------------------
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    state = const AuthLoading();
    try {
      final result = await _authService.signup(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword, // forwarded as you intended
      );

      final dynamic userField = result['user'];
      final User user = switch (userField) {
        User u => u,
        Map<String, dynamic> m => User.fromJson(m),
        _ => throw Exception('Invalid user payload from API'),
      };

      final String? token = result['token'] as String?;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(user.toJson()));
      if (token != null && token.isNotEmpty) {
        await _secureStorage.write(key: 'accessToken', value: token);
      }

      state = AuthAuthenticated(user);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  // ------------------------------------------------------------
  // Forgot / Verify / Reset (kept your logic)
  // ------------------------------------------------------------
  Future<void> forgotPassword(String email) async {
    state = const AuthLoading();
    try {
      await _authService.forgotPassword(email);
      state = const AuthForgotPasswordSent();
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> verifyResetCode(String resetCode) async {
    state = const AuthLoading();
    try {
      await _authService.verifyResetCode(resetCode);
      state = const AuthVerifyingResetCode();
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> resetPassword(String email, String newPassword) async {
    state = const AuthLoading();
    try {
      final String? token =
          await _authService.resetPassword(email: email, newPassword: newPassword);

      // Many backends don't return a token here; keep it optional
      if (token != null && token.isNotEmpty) {
        await _secureStorage.write(key: 'accessToken', value: token);
      }

      state = const AuthResetPasswordSuccess();
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  // ------------------------------------------------------------
  // Logout
  // ------------------------------------------------------------
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await _secureStorage.delete(key: 'accessToken');
    state = const AuthUnauthenticated();
  }
}
