// lib/features/auth/services/user_remote_Service.dart
// Keep filename casing to match your imports.
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class UserRemoteService {
  late final Dio _dio;
  UserRemoteService({required String token}) {
    final base = _resolveBase();
    _dio = Dio(
      BaseOptions(
        baseUrl: '$base/api/v1',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }

  String _resolveBase() {
    if (kIsWeb) return 'http://localhost:5000';
    if (Platform.isAndroid) return 'http://10.0.2.2:5000';
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

  Future<Map<String, dynamic>> getProfile() async {
    final res = await _dio.get('/users/me');
    return _ok<Map<String, dynamic>>(res);
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> payload) async {
    final res = await _dio.patch('/users/updateMe', data: payload);
    return _ok<Map<String, dynamic>>(res);
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final res = await _dio.patch('/users/changeMyPassword', data: {
      'currentPassword': currentPassword,
      'password': newPassword,
      'passwordConfirm': newPassword,
    });
    return _ok<Map<String, dynamic>>(res);
  }
}
