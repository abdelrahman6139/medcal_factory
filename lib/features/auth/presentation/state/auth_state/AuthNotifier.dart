import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pharma_app/features/auth/models/user.dart';
import 'package:pharma_app/features/auth/presentation/state/auth_state/AuthState.dart';
import 'package:pharma_app/features/auth/services/auth_remote_service.dart';
import 'package:shared_preferences/shared_preferences.dart';



class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRemoteService _authService;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AuthNotifier(this._authService) : super(const AuthInitial()) {
    _checkAuthStatus();
  }

  /// 🔍 Check if user is already logged in
  Future<void> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    final token = await _secureStorage.read(key: 'accessToken');

    if (userJson != null && token != null) {
      final user = User.fromJson(jsonDecode(userJson));
      state = AuthAuthenticated(user);
    } else {
      state = const AuthUnauthenticated();
    }
  }

  /// 🔑 Login
  Future<void> login(String email, String password) async {
    state = const AuthLoading();
    try {
      final result = await _authService.login(email: email, password: password);
      final user = result['user'] as User;
      final token = result['token'] as String?;
      print("token$token}");

      // ✅ Save user + token in cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(user.toJson()));
      if (token != null) {
        await _secureStorage.write(key: 'accessToken', value: token);
        final check = await _secureStorage.read(key: 'accessToken');
        print("🔑 Saved token in secure storage: $check");
      }

      state = AuthAuthenticated(user);
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
        confirmPassword: confirmPassword, // ✅ Pass confirm password
      );

      final user = result['user'] as User;
      final token = result['token'] as String?;

      // ✅ Save user + token in cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(user.toJson()));
      if (token != null) {
        await _secureStorage.write(key: 'accessToken', value: token);
      }

      state = AuthAuthenticated(user);
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
      final token =
      await _authService.resetPassword(email: email, newPassword: newPassword);
      // Usually fetch user again after reset
      if (token != null) {
        await _secureStorage.write(key: 'accessToken', value: token);
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
    state = const AuthUnauthenticated();
  }

  void setAuthenticated(Map<String, dynamic> userJson, String token) {
    final user = User.fromJson(userJson);
    state = AuthAuthenticated(user);
  }
}

/// Riverpod provider (inject service into notifier)
final authNotifierProvider =
StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(AuthRemoteService());
});
