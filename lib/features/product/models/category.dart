// lib/models/category_model.dart
class Category {
  final String id;
  final String name;
  final String slug;
  final String? image;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    this.image,
  });

  // Deserialize JSON from backend
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'],
      name: json['name'],
      slug: json['slug'],
      image: json['image'],
    );
  }

  // Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'slug': slug,
      'image': image,
    };
  }
}
