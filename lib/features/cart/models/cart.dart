// lib/models/cart_model.dart
import '../../product/models/product.dart';

class Cart {
  final String id;
  final List<CartItem> cartItems;
  final double totalCartPrice;
  final double? totalPriceAfterDiscount;

  Cart({
    required this.id,
    required this.cartItems,
    required this.totalCartPrice,
    this.totalPriceAfterDiscount,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['_id'],
      cartItems: (json['cartItems'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList(),
      totalCartPrice: (json['totalCartPrice'] ?? 0).toDouble(),
      totalPriceAfterDiscount: json['totalPriceAfterDiscount'] != null
          ? (json['totalPriceAfterDiscount'] as num).toDouble()
          : null,
    );
  }
}

class CartItem {
  final String id;
  final Product product;
  final int quantity;
  final String? color;
  final double price;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    this.color,
    required this.price,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['_id'],
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
      color: json['color'],
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}
