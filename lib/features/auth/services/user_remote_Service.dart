// lib/services/user_service.dart
import 'dart:io';
import 'package:dio/dio.dart';
import '../models/user.dart';

class UserService {
  late Dio _dio;

  UserService(String token) {
    _dio = Dio(
      BaseOptions(
        baseUrl: "http://10.0.2.2:5000/api/v1", // change if needed
        connectTimeout: Duration(seconds: 5),
        receiveTimeout: Duration(seconds: 3),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      ),
    );
  }

  // GET all users
  Future<List<User>> getUsers() async {
    try {
      final response = await _dio.get("/users");
      final List<dynamic> data = response.data['data'];
      return data.map((json) => User.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message);
    }
  }

  // GET a single user
  Future<User> getUser(String id) async {
    try {
      final response = await _dio.get("/users/$id");
      return User.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message);
    }
  }

  // UPDATE a user
  Future<User> updateUser(String id, Map<String, dynamic> updates) async {
    try {
      final response = await _dio.put("/users/$id", data: updates);
      return User.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message);
    }
  }

  // DELETE a user
  Future<void> deleteUser(String id) async {
    try {
      await _dio.delete("/users/$id");
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message);
    }
  }

  // UPLOAD profile image
  Future<User> uploadProfileImage(String id, File imageFile) async {
    try {
      String fileName = imageFile.path.split('/').last;

      FormData formData = FormData.fromMap({
        "profileImg": await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await _dio.put("/users/$id", data: formData);
      return User.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message);
    }
  }
}
