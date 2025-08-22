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
  final Category? category; // <-- here

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
      id: json['_id'],
      title: json['title'],
      slug: json['slug'],
      description: json['description'],
      quantity: json['quantity'],
      sold: json['sold'],
      price: json['price'].toDouble(),
      priceAfterDiscount: json['priceAfterDiscount']?.toDouble(),
      colors: json['colors'] != null ? List<String>.from(json['colors']) : null,
      imageCover: json['imageCover'],
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
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
