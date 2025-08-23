// lib/services/wishlist_service.dart
import 'package:dio/dio.dart';
import '../../product/models/product.dart';

class WishlistService {
  final Dio _dio;

  WishlistService(String token)
      : _dio = Dio(BaseOptions(
    baseUrl: "http://localhost:5000/api/v1",
    headers: {"Authorization": "Bearer $token"},
  ));

  // Get wishlist
  Future<List<Product>> getWishlist() async {
    final response = await _dio.get("/wishlist");
    return (response.data['data'] as List)
        .map((prod) => Product.fromJson(prod))
        .toList();
  }

  // Add product to wishlist
  Future<List<Product>> addProductToWishlist(String productId) async {
    final response = await _dio.post("/wishlist", data: {"productId": productId});
    return (response.data['data'] as List)
        .map((prod) => Product.fromJson(prod))
        .toList();
  }

  // Remove product from wishlist
  Future<List<Product>> removeProductFromWishlist(String productId) async {
    final response = await _dio.delete("/wishlist/$productId");
    return (response.data['data'] as List)
        .map((prod) => Product.fromJson(prod))
        .toList();
  }
}
