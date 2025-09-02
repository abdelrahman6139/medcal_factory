import 'package:pharma_app/features/product/models/product.dart';

class Cart {
  final String id;                // 🆕 cart ID
  final List<CartItem> cartItems;
  final double totalCartPrice;

  Cart({
    required this.id,
    required this.cartItems,
    required this.totalCartPrice,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

    return Cart(
      id: data['_id'] as String, // 🆕 assumes backend sends `_id`
      cartItems: (data['cartItems'] as List<dynamic>)
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCartPrice: (data['totalCartPrice'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id, // 🆕 persist cart ID
      "cartItems": cartItems.map((e) => e.toJson()).toList(),
      "totalCartPrice": totalCartPrice,
    };
  }
}


class CartItem {
  final String id;
  final int quantity;
  final double price;
  final Product product;

  CartItem({
    required this.id,
    required this.quantity,
    required this.price,
    required this.product,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final productData = json['product'];

    return CartItem(
      id: json['_id'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
      product: productData is Map<String, dynamic>
          ? Product.fromJson(productData)
          : Product(
        id: productData as String, // only ID available
        title: "Unknown",          // fallback values
        slug: "",
        description: "",
        quantity: 0,
        sold: 0,
        price: 0,
        imageCover: "",
        category: null
      ),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "quantity": quantity,
      "price": price,
      "product": product.toJson(),
    };
  }
}
