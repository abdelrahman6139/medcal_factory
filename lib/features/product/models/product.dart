// lib/models/product.dart
import 'category.dart';

class Product {
  final String id;
  final String title;
  final String slug;
  final String description;
  final int quantity;
  final int sold;
  final double price;
  final double? priceAfterDiscount;
  final List<String>? colors;
  final String imageCover;
  final List<String>? images;
  final Category? category;

  // 🔹 حقول طبية (اختيارية)
  final String? composition;
  final String? indication;
  final String? pharmacologicalActions;
  final String? dosage;
  final String? warnings;
  final String? leafletUrl;
  final double? ratingsAverage;
  final int? ratingsQuantity;
  Product({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    required this.quantity,
    required this.sold,
    required this.price,
    this.priceAfterDiscount,
    this.colors,
    required this.imageCover,
    this.images,
    this.category,
    // 🔹 الجديدة
    this.composition,
    this.indication,
    this.pharmacologicalActions,
    this.dosage,
    this.warnings,
    this.leafletUrl,
    this.ratingsAverage,
    this.ratingsQuantity,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      quantity: (json['quantity'] ?? 0) as int,
      sold: (json['sold'] ?? 0) as int,
      price: ((json['price'] ?? 0) as num).toDouble(),
      priceAfterDiscount:
          json['priceAfterDiscount'] != null
              ? ((json['priceAfterDiscount'] as num).toDouble())
              : null,
      colors:
          (json['colors'] is List)
              ? List<String>.from(
                (json['colors'] as List).map((e) => e.toString()),
              )
              : null,
      imageCover: (json['imageCover'] ?? '').toString(),
      images:
          (json['images'] is List)
              ? List<String>.from(
                (json['images'] as List).map((e) => e.toString()),
              )
              : null,
      category:
          (json['category'] is Map<String, dynamic>)
              ? Category.fromJson(Map<String, dynamic>.from(json['category']))
              : null,

      // 🔹 الجديدة
      composition: _optStr(json['composition']),
      indication: _optStr(json['indication']),
      pharmacologicalActions: _optStr(json['pharmacologicalActions']),
      dosage: _optStr(json['dosage']),
      warnings: _optStr(json['warnings']),
      leafletUrl: _optStr(json['leafletUrl']),
      ratingsAverage:
          (json['ratingsAverage'] ?? json['ratingsAvg']) == null
              ? null
              : ((json['ratingsAverage'] ?? json['ratingsAvg']) as num)
                  .toDouble(),
      ratingsQuantity: (json['ratingsQuantity'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'slug': slug,
      'description': description,
      'quantity': quantity,
      'sold': sold,
      'price': price,
      'priceAfterDiscount': priceAfterDiscount,
      'colors': colors,
      'imageCover': imageCover,
      'images': images,
      'category': category?.toJson(),

      // 🔹 الجديدة
      'composition': composition,
      'indication': indication,
      'pharmacologicalActions': pharmacologicalActions,
      'dosage': dosage,
      'warnings': warnings,
      'leafletUrl': leafletUrl,
      'ratingsAverage': ratingsAverage,
      'ratingsQuantity': ratingsQuantity,
    };
  }

  // Helper: يحوّل أي قيمة إلى String? بشكل آمن
  static String? _optStr(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }
}
