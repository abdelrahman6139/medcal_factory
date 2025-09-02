// lib/features/cart/services/cart_api_service.dart
import 'package:dio/dio.dart';
import 'package:pharma_app/features/cart/models/cart.dart';

/// Service class responsible for interacting with the Cart API.
/// Provides methods for fetching, adding, updating, and deleting cart items.
class CartApiService {
  final Dio _dio;
  final String _authToken;

  CartApiService({required String baseUrl, required String authToken})
      : _authToken = authToken,
        _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $authToken',
            },
          ),
        );

  /// Fetches the logged-in user's cart from the backend.
  Future<Cart> fetchCart() async {
    const endpoint = '/cart';
    try {
      _logRequest('GET', endpoint, null);
      final response = await _dio.get(endpoint);
      _logResponse(endpoint, response.data);

      final data = response.data['data'];
      return Cart.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Adds a product to the cart.
  Future<Cart> addProductToCart(String productId, {String? color}) async {
    const endpoint = '/cart';
    final body = {'productId': productId, 'color': color};
    try {
      _logRequest('POST', endpoint, body);
      final response = await _dio.post(endpoint, data: body);
      _logResponse(endpoint, response.data);

      final data = response.data['data'];
      return Cart.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Updates the quantity of a specific cart item.
  Future<Cart> updateCartItemQuantity(String itemId, int quantity) async {
    final endpoint = '/cart/$itemId';
    final body = {'quantity': quantity};
    try {
      _logRequest('PUT', endpoint, body);
      final response = await _dio.put(endpoint, data: body);
      _logResponse(endpoint, response.data);

      final data = response.data['data'];
      return Cart.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Removes a specific item from the cart.
  Future<Cart> removeCartItem(String itemId) async {
    final endpoint = '/cart/$itemId';
    try {
      _logRequest('DELETE', endpoint, null);
      final response = await _dio.delete(endpoint);
      _logResponse(endpoint, response.data);

      final data = response.data['data'];
      return Cart.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Clears the entire cart for the logged-in user.
  Future<void> clearCart() async {
    const endpoint = '/cart';
    try {
      _logRequest('DELETE', endpoint, null);
      final response = await _dio.delete(endpoint);
      _logResponse(endpoint, response.data);

      if (response.statusCode != 204) {
        throw Exception('Failed to clear cart');
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Applies a coupon to the logged-in user's cart.
  Future<Cart> applyCoupon(String couponCode) async {
    const endpoint = '/cart/applyCoupon';
    final body = {'coupon': couponCode};
    try {
      _logRequest('PUT', endpoint, body);
      final response = await _dio.put(endpoint, data: body);
      _logResponse(endpoint, response.data);

      final data = response.data['data'];
      return Cart.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Handles Dio-specific errors and provides a readable message.
  String _handleError(DioException e) {
    if (e.response != null) {
      return 'Error: ${e.response?.data['message'] ?? e.message}';
    } else {
      return 'Network error: ${e.message}';
    }
  }

  /// Debug log for requests
  void _logRequest(String method, String endpoint, dynamic data) {
    print('🔹 [REQUEST]');
    print('  Token: $_authToken');
    print('  Method: $method');
    print('  URL: ${_dio.options.baseUrl}$endpoint');
    print('  Data Sent: ${data ?? "No body"}');
  }

  /// Debug log for responses
  void _logResponse(String endpoint, dynamic data) {
    print('✅ [RESPONSE]');
    print('  URL: ${_dio.options.baseUrl}$endpoint');
    print('  Data Received: $data');
  }
}
