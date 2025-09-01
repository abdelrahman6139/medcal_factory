// lib/services/category_service.dart
import 'dart:io';
import 'package:dio/dio.dart';
import '../models/category.dart';

class CategoryService {
  late Dio _dio;

  CategoryService(String token) {
    _dio = Dio(
      BaseOptions(
        baseUrl: "http://localhost:5000/api/v1",
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      ),
    );
  }

  // GET all categories
  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get("/categories");
      final List<dynamic> data = response.data['data'];
      return data.map((json) => Category.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message);
    }
  }

  // GET single category by ID
  Future<Category> getCategory(String id) async {
    try {
      final response = await _dio.get("/categories/$id");
      return Category.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message);
    }
  }

  // CREATE category
  Future<Category> createCategory({
    required String name,
    required File? image,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        "name": name,
        if (image != null)
          "image": await MultipartFile.fromFile(
            image.path,
            filename: image.path.split('/').last,
          ),
      });

      final response = await _dio.post("/categories", data: formData);
      return Category.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message);
    }
  }

  // UPDATE category
  Future<Category> updateCategory({
    required String id,
    String? name,
    File? image,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        if (name != null) "name": name,
        if (image != null)
          "image": await MultipartFile.fromFile(
            image.path,
            filename: image.path.split('/').last,
          ),
      });

      final response = await _dio.put("/categories/$id", data: formData);
      return Category.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message);
    }
  }

  // DELETE category
  Future<void> deleteCategory(String id) async {
    try {
      await _dio.delete("/categories/$id");
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message);
    }
  }
}
