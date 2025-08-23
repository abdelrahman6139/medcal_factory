// lib/models/review_model.dart
import '../../auth/models/user.dart';
import 'product.dart';

class Review {
  final String id;
  final String? title;
  final double ratings;
  final String userId;
  final User user;
  final String productId;
  final Product product;

  Review({
    required this.id,
    this.title,
    required this.ratings,
    required this.userId,
    required this.user,
    required this.productId,
    required this.product,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['_id'],
      title: json['title'],
      ratings: (json['ratings'] ?? 0).toDouble(),
      userId: json['user']?['_id'] ?? '',
      user: User.fromJson(json['user']),
      productId: json['product']?['_id'] ?? '',
      product: Product.fromJson(json['product']),
    );
  }
}
