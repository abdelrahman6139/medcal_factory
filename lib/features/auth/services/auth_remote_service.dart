// lib/services/auth_remote_service.dart
import 'package:dio/dio.dart';
import '../models/user.dart';

class AuthRemoteService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://10.0.2.2:5000/api/v1/auth",
      connectTimeout: Duration(seconds: 5),
      receiveTimeout: Duration(seconds: 5),
    ),
  );

  // Signup
  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _dio.post(
        '/signup',
        data: {
          "name": name,
          "email": email,
          "password": password,
          "passwordConfirm": confirmPassword, // ✅ Added
        },
      );

      final data = response.data;
      final user = User.fromJson(data['data']);
      final token = data['token'];

      return {
        "user": user,
        "token": token,
      };
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message);
    }
  }


  // Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {
          "email": email,
          "password": password,
        },
      );

      final data = response.data;
      final user = User.fromJson(data['data']);
      final token = data['token'];

      return {
        "user": user,
        "token": token,
      };
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message);
    }
  }

  // Forgot Password
  Future<void> forgotPassword(String email) async {
    try {
      await _dio.post(
        '/forgotPassword',
        data: {"email": email},
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message);
    }
  }

  // Verify Reset Code
  Future<void> verifyResetCode(String resetCode) async {
    try {
      await _dio.post(
        '/verifyResetCode',
        data: {"resetCode": resetCode},
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message);
    }
  }

  // Reset Password
  Future<String> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        '/resetPassword',
        data: {
          "email": email,
          "newPassword": newPassword,
        },
      );
      return response.data['token'];
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message);
    }
  }
}
