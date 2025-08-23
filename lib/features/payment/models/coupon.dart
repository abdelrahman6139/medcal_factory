// lib/models/coupon_model.dart
class Coupon {
  final String id;
  final String name;
  final DateTime expire;
  final double discount;

  Coupon({
    required this.id,
    required this.name,
    required this.expire,
    required this.discount,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['_id'],
      name: json['name'],
      expire: DateTime.parse(json['expire']),
      discount: (json['discount'] ?? 0).toDouble(),
    );
  }
}
