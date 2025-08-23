// lib/services/product_service.dart
import 'dart:io';
import 'package:dio/dio.dart';
import '../models/product.dart';

class ProductService {
  late Dio _dio;

  ProductService(String token) {
    _dio = Dio(
      BaseOptions(
        baseUrl: "http://10.0.2.2:5000/api/v1",
        connectTimeout: Duration(seconds: 5),
        receiveTimeout: Duration(seconds: 3),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      ),
    );
  }

  // GET all products
  Future<List<Product>> getProducts() async {
    try {
      final response = await _dio.get("/products");
      print(response);
      final List<dynamic> data = response.data['data'];
      return data.map((json) => Product.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message);
    }
  }

  // GET single product
  Future<Product> getProduct(String id) async {
    try {
      final response = await _dio.get("/products/$id");
      return Product.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message);
    }
  }

  // CREATE product
  Future<Product> createProduct(Map<String, dynamic> productData) async {
    try {
      final response = await _dio.post("/products", data: productData);
      return Product.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message);
    }
  }

  // UPDATE product
  Future<Product> updateProduct(String id, Map<String, dynamic> updates) async {
    try {
      final response = await _dio.put("/products/$id", data: updates);
      return Product.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message);
    }
  }

  // DELETE product
  Future<void> deleteProduct(String id) async {
    try {
      await _dio.delete("/products/$id");
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message);
    }
  }

  // UPLOAD product images (cover + gallery)
  Future<Product> uploadProductImages(
      String id, File imageCover, List<File> images) async {
    try {
      final Map<String, MultipartFile> fileMap = {};
      fileMap['imageCover'] = await MultipartFile.fromFile(
        imageCover.path,
        filename: imageCover.path.split('/').last,
      );

      final imageList = await Future.wait(images.map((file) async {
        return await MultipartFile.fromFile(file.path,
            filename: file.path.split('/').last);
      }));

      FormData formData = FormData.fromMap({
        "imageCover": fileMap['imageCover'],
        "images": imageList,
      });

      final response = await _dio.put("/products/$id", data: formData);
      return Product.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message);
    }
  }
}
