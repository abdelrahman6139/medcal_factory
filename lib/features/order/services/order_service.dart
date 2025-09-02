import 'package:dio/dio.dart';
import 'package:pharma_app/features/order/models/order.dart';

class OrderApiService {
  final Dio _dio;

  OrderApiService({Dio? dio})
      : _dio = dio ??
      Dio(
        BaseOptions(
          baseUrl: "http://10.0.2.2:5000/api/v1/orders",
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );

  /// Fetch all orders for the logged-in user
  Future<List<Order>> fetchAllOrders({required String token}) async {
    try {
      final response = await _dio.get(
        "/",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      final List data = response.data['data'];
      return data.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      throw Exception("Failed to fetch orders: $e");
    }
  }

  /// Fetch a specific order by ID
  Future<Order> fetchOrderById({
    required String token,
    required String orderId,
  }) async {
    try {
      final response = await _dio.get(
        "/$orderId",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      return Order.fromJson(response.data['data']);
    } catch (e) {
      throw Exception("Failed to fetch order $orderId: $e");
    }
  }

  /// Create a new cash order from a cartId
  Future<Order> createCashOrder({
    required String token,
    required String cartId,
    required Map<String, dynamic> shippingAddress,
  }) async {
    try {
      print(token);
      print(cartId);
      final response = await _dio.post(
        "/$cartId",
        data: {"shippingAddress": shippingAddress},
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      return Order.fromJson(response.data['data']);
    } catch (e) {
      throw Exception("Failed to create order: $e");
    }
  }
  /// Delete/cancel an order by ID
  Future<void> cancelOrder({
    required String token,
    required String orderId,
  }) async {
    try {
      await _dio.delete(
        "/$orderId",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
    } catch (e) {
      throw Exception("Failed to cancel order $orderId: $e");
    }
  }

  /// Mark an order as paid (Admin/Manager access)
  Future<Order> updateOrderToPaid({
    required String token,
    required String orderId,
  }) async {
    try {
      final response = await _dio.put(
        "/$orderId/pay",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      return Order.fromJson(response.data['data']);
    } catch (e) {
      throw Exception("Failed to update order to paid: $e");
    }
  }

  /// Mark an order as delivered (Admin/Manager access)
  Future<Order> updateOrderToDelivered({
    required String token,
    required String orderId,
  }) async {
    try {
      final response = await _dio.put(
        "/$orderId/deliver",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      return Order.fromJson(response.data['data']);
    } catch (e) {
      throw Exception("Failed to update order to delivered: $e");
    }
  }
}
