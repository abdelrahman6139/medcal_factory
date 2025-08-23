// lib/models/order_model.dart
import '../../cart/models/cart.dart';
import '../../auth/models/user.dart';

class Order {
  final String id;
  final User user;
  final List<CartItem> cartItems;
  final double taxPrice;
  final double shippingPrice;
  final double totalOrderPrice;
  final String paymentMethodType;
  final bool isPaid;
  final DateTime? paidAt;
  final bool isDelivered;
  final DateTime? deliveredAt;

  Order({
    required this.id,
    required this.user,
    required this.cartItems,
    required this.taxPrice,
    required this.shippingPrice,
    required this.totalOrderPrice,
    required this.paymentMethodType,
    required this.isPaid,
    this.paidAt,
    required this.isDelivered,
    this.deliveredAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'],
      user: User.fromJson(json['user']),
      cartItems: (json['cartItems'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList(),
      taxPrice: (json['taxPrice'] ?? 0).toDouble(),
      shippingPrice: (json['shippingPrice'] ?? 0).toDouble(),
      totalOrderPrice: (json['totalOrderPrice'] ?? 0).toDouble(),
      paymentMethodType: json['paymentMethodType'] ?? 'cash',
      isPaid: json['isPaid'] ?? false,
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
      isDelivered: json['isDelivered'] ?? false,
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'])
          : null,
    );
  }
}

