// lib/services/order_service.dart
import 'package:dio/dio.dart';
import '../models/order.dart';

class OrderService {
  late Dio _dio;

  OrderService(String token) {
    _dio = Dio(
      BaseOptions(
        baseUrl: "http://localhost:5000/api/v1",
        headers: {"Authorization": "Bearer $token"},
      ),
    );
  }

  // GET all orders for logged user
  Future<List<Order>> getOrders() async {
    final response = await _dio.get("/orders");
    final List<dynamic> data = response.data['data'];
    return data.map((json) => Order.fromJson(json)).toList();
  }

  // GET specific order
  Future<Order> getOrder(String id) async {
    final response = await _dio.get("/orders/$id");
    return Order.fromJson(response.data['data']);
  }

  // CREATE cash order
  Future<Order> createCashOrder({
    required String cartId,
    required Map<String, dynamic> shippingAddress,
  }) async {
    final response = await _dio.post("/orders/$cartId", data: {
      "shippingAddress": shippingAddress,
    });
    return Order.fromJson(response.data['data']);
  }

  // UPDATE order to paid
  Future<Order> markOrderPaid(String orderId) async {
    final response = await _dio.put("/orders/$orderId/pay");
    return Order.fromJson(response.data['data']);
  }

  // UPDATE order to delivered
  Future<Order> markOrderDelivered(String orderId) async {
    final response = await _dio.put("/orders/$orderId/deliver");
    return Order.fromJson(response.data['data']);
  }
}
