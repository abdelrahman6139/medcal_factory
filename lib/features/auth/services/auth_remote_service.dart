// lib/features/auth/services/auth_remote_service.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pharma_app/features/auth/models/user.dart';

class AuthRemoteService {
  late final Dio _dio;
  AuthRemoteService() {
    final base = _resolveBase();
    _dio = Dio(
      BaseOptions(
        baseUrl: '$base/api/v1/auth',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  String _resolveBase() {
    if (kIsWeb) return 'http://localhost:5000';
    if (Platform.isAndroid) return 'http://10.0.2.2:5000'; // Android emulator → host
    return 'http://localhost:5000';
  }

  T _ok<T>(Response res) {
    if ((res.statusCode ?? 500) >= 200 && (res.statusCode ?? 500) < 300) {
      return res.data as T;
    }
    throw DioException(
      requestOptions: res.requestOptions,
      response: res,
      error: 'HTTP ${res.statusCode}: ${res.data}',
      type: DioExceptionType.badResponse,
    );
  }

  Map<String, dynamic> _unwrap(Response res) => _ok<Map<String, dynamic>>(res);

  User _parseUser(Map<String, dynamic> data) {
    if (data['user'] is Map) return User.fromJson(data['user'] as Map<String, dynamic>);
    if (data['data'] is Map && (data['data'] as Map)['user'] is Map) {
      return User.fromJson((data['data'] as Map)['user'] as Map<String, dynamic>);
    }
    // Some backends return the user at top level
    return User.fromJson(data);
  }

  String? _parseToken(Map<String, dynamic> data) {
    if (data['token'] is String) return data['token'] as String;
    if (data['data'] is Map && (data['data'] as Map)['token'] is String) {
      return (data['data'] as Map)['token'] as String;
    }
    return null;
  }

  /// Returns {'user': User, 'token': String}
  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    required String confirmPassword, // <-- matches your UI/Notifier call
  }) async {
    final res = await _dio.post('/signup', data: {
      'name': name,
      'email': email,
      'password': password,
      // send both keys so it works with either backend spelling
      'confirmPassword': confirmPassword,
      'passwordConfirm': confirmPassword,
    });
    final data = _unwrap(res);
    final user = _parseUser(data);
    final token = _parseToken(data) ?? '';
    return {'user': user, 'token': token};
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post('/login', data: {'email': email, 'password': password});
    final data = _unwrap(res);
    final user = _parseUser(data);
    final token = _parseToken(data) ?? '';
    return {'user': user, 'token': token};
  }

  Future<void> forgotPassword(String email) async {
    final res = await _dio.post('/forgotPassword', data: {'email': email});
    _ok(res);
  }

  Future<void> verifyResetCode(String resetCode) async {
    final res = await _dio.post('/verifyResetCode', data: {'resetCode': resetCode});
    _ok(res);
  }

  /// Returns new token (if backend sends one)
  Future<String> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    final res = await _dio.put('/resetPassword', data: {
      'email': email,
      'newPassword': newPassword,
    });
    final data = _unwrap(res);
    return _parseToken(data) ?? '';
  }

  /// Google: exchange device ID token for your app session
  /// Sends multiple field names so it works with different backend shapes.
  /// Also exposes server error text on 4xx so you can see what's wrong.
  Future<Map<String, dynamic>> googleLogin({required String idToken}) async {
    try {
      final res = await _dio.post(
        '/google',
        data: {
          'idToken': idToken,     // common
          'tokenId': idToken,     // some tutorials use this
          'credential': idToken,  // Google Identity Services (web) uses this
        },
        // Let 4xx through so we can read server message
        options: Options(validateStatus: (s) => s != null && s < 500),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = _unwrap(res);
        final user = _parseUser(data);
        final token = _parseToken(data) ?? '';
        return {'user': user, 'token': token};
      }

      // Surface backend message for 400/401/etc
      final body = res.data;
      final message = (body is Map && body['message'] is String)
          ? body['message'] as String
          : body?.toString();
      throw Exception('Google login ${res.statusCode}: ${message ?? 'Bad request'}');
    } on DioException catch (e) {
      final server = e.response?.data;
      final message = (server is Map && server['message'] is String)
          ? server['message'] as String
          : server?.toString() ?? e.message;
      throw Exception('Google login failed: $message');
    }
  }

  /// Get current user with token
  Future<User> me(String token) async {
    final res = await _dio.get('/me', options: Options(headers: {
      'Authorization': 'Bearer $token',
    }));
    final data = _unwrap(res);
    return _parseUser(data);
  }
}
