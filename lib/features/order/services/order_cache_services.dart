import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pharma_app/features/order/models/order.dart';

class OrderCacheService {
  static const String _ordersKey = "cached_orders";

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Save list of orders to secure storage
  Future<void> saveOrders(List<Order> orders) async {
    final List<Map<String, dynamic>> jsonOrders =
    orders.map((order) => _orderToJson(order)).toList();

    await _secureStorage.write(
      key: _ordersKey,
      value: jsonEncode(jsonOrders),
    );
  }

  /// Retrieve list of orders from secure storage
  Future<List<Order>> getOrders() async {
    final String? jsonStr = await _secureStorage.read(key: _ordersKey);

    if (jsonStr == null) return [];

    final List<dynamic> jsonOrders = jsonDecode(jsonStr);
    return jsonOrders.map((json) => Order.fromJson(json)).toList();
  }

  /// Clear cached orders from secure storage
  Future<void> clearOrders() async {
    await _secureStorage.delete(key: _ordersKey);
  }

  /// Convert Order object into JSON for secure caching
  Map<String, dynamic> _orderToJson(Order order) {
    return {
      "id": order.id,
      "user": order.userId,
      "cartItems": order.cartItems.map((item) => item.toJson()).toList(),
      "taxPrice": order.taxPrice,
      "shippingPrice": order.shippingPrice,
      "totalOrderPrice": order.totalOrderPrice,
      "paymentMethodType": order.paymentMethodType,
      "isPaid": order.isPaid,
      "paidAt": order.paidAt?.toIso8601String(),
      "isDelivered": order.isDelivered,
      "deliveredAt": order.deliveredAt?.toIso8601String(),
    };
  }
}
