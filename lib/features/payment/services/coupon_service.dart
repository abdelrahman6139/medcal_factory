// lib/services/cart_service.dart
import 'package:dio/dio.dart';
import '../../cart/models/cart.dart';
import '../models/coupon.dart';

class CartService {
  late Dio _dio;

  CartService(String token) {
    _dio = Dio(
      BaseOptions(
        baseUrl: "http://localhost:5000/api/v1",
        headers: {"Authorization": "Bearer $token"},
      ),
    );
  }

  // Get user cart
  Future<Cart> getCart() async {
    final response = await _dio.get("/cart");
    return Cart.fromJson(response.data['data']);
  }

  // Add product to cart
  Future<Cart> addProductToCart({
    required String productId,
    String? color,
  }) async {
    final response = await _dio.post("/cart", data: {
      "productId": productId,
      "color": color,
    });
    return Cart.fromJson(response.data['data']);
  }

  // Remove specific cart item
  Future<Cart> removeCartItem(String itemId) async {
    final response = await _dio.delete("/cart/$itemId");
    return Cart.fromJson(response.data['data']);
  }

  // Clear cart
  Future<void> clearCart() async {
    await _dio.delete("/cart");
  }

  // Update cart item quantity
  Future<Cart> updateCartItemQuantity({
    required String itemId,
    required int quantity,
  }) async {
    final response = await _dio.put("/cart/$itemId", data: {"quantity": quantity});
    return Cart.fromJson(response.data['data']);
  }

  // Apply coupon
  Future<Cart> applyCoupon(String couponName) async {
    final response = await _dio.put("/cart/applyCoupon", data: {"coupon": couponName});
    return Cart.fromJson(response.data['data']);
  }
}
