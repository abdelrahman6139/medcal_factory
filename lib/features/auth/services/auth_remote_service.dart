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

  // --- 🔹 SIGNUP ---
  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    const endpoint = '/signup';
    final body = {
      "name": name,
      "email": email,
      "password": password,
      "passwordConfirm": confirmPassword,
    };

    try {
      _logRequest('POST', endpoint, body);
      final response = await _dio.post(endpoint, data: body);
      _logResponse(endpoint, response.data);

      final data = response.data;
      final user = User.fromJson(data['data']);
      final token = data['token'];

      return {
        "user": user,
        "token": token,
      };
    } on DioException catch (e) {
      _logError(endpoint, e);
      throw Exception(e.response?.data ?? e.message);
    }
  }

  // --- 🔹 LOGIN ---
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    const endpoint = '/login';
    final body = {
      "email": email,
      "password": password,
    };

    try {
      _logRequest('POST', endpoint, body);
      final response = await _dio.post(endpoint, data: body);
      _logResponse(endpoint, response.data);

      final data = response.data;
      final user = User.fromJson(data['data']);
      final token = data['token'];

      return {
        "user": user,
        "token": token,
      };
    } on DioException catch (e) {
      _logError(endpoint, e);
      throw Exception(e.response?.data ?? e.message);
    }
  }

  // --- 🔹 FORGOT PASSWORD ---
  Future<void> forgotPassword(String email) async {
    const endpoint = '/forgotPassword';
    final body = {"email": email};

    try {
      _logRequest('POST', endpoint, body);
      final response = await _dio.post(endpoint, data: body);
      _logResponse(endpoint, response.data);
    } on DioException catch (e) {
      _logError(endpoint, e);
      throw Exception(e.response?.data ?? e.message);
    }
  }

  // --- 🔹 VERIFY RESET CODE ---
  Future<void> verifyResetCode(String resetCode) async {
    const endpoint = '/verifyResetCode';
    final body = {"resetCode": resetCode};

    try {
      _logRequest('POST', endpoint, body);
      final response = await _dio.post(endpoint, data: body);
      _logResponse(endpoint, response.data);
    } on DioException catch (e) {
      _logError(endpoint, e);
      throw Exception(e.response?.data ?? e.message);
    }
  }

  // --- 🔹 RESET PASSWORD ---
  Future<String> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    const endpoint = '/resetPassword';
    final body = {
      "email": email,
      "newPassword": newPassword,
    };

    try {
      _logRequest('POST', endpoint, body);
      final response = await _dio.post(endpoint, data: body);
      _logResponse(endpoint, response.data);

      return response.data['token'];
    } on DioException catch (e) {
      _logError(endpoint, e);
      throw Exception(e.response?.data ?? e.message);
    }
  }

  // --- 🔹 Logging Helpers ---
  void _logRequest(String method, String endpoint, dynamic data) {
    print('🔹 [REQUEST]');
    print('  Method: $method');
    print('  URL: ${_dio.options.baseUrl}$endpoint');
    print('  Data Sent: ${data ?? "No body"}');
  }

  void _logResponse(String endpoint, dynamic data) {
    print('✅ [RESPONSE]');
    print('  URL: ${_dio.options.baseUrl}$endpoint');
    print('  Data Received: $data');
  }

  void _logError(String endpoint, DioException e) {
    print('❌ [ERROR]');
    print('  URL: ${_dio.options.baseUrl}$endpoint');
    print('  Message: ${e.message}');
    if (e.response != null) {
      print('  Status Code: ${e.response?.statusCode}');
      print('  Error Data: ${e.response?.data}');
    }
  }
}
