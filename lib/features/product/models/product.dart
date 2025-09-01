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
              ? List<String>.from(json['colors'].map((e) => e.toString()))
              : null,
      // ✅ لو السيرفر مرجعش صورة دلوقتي، نخليها فاضية بدل null
      imageCover: (json['imageCover'] ?? '').toString(),
      images:
          (json['images'] is List)
              ? List<String>.from(json['images'].map((e) => e.toString()))
              : null,
      category:
          (json['category'] is Map<String, dynamic>)
              ? Category.fromJson(Map<String, dynamic>.from(json['category']))
              : null,
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
    };
  }
}
