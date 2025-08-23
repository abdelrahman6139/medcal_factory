// lib/models/user.dart
class User {
  final String id;
  final String name;
  final String? slug;
  final String email;
  final String? phone;
  final String? profileImg;
  final String role;
  final bool active;
  final String? token; // make it optional, pass when available

  User({
    required this.id,
    required this.name,
    this.slug,
    required this.email,
    this.phone,
    this.profileImg,
    required this.role,
    required this.active,
    this.token,
  });

  // Convert JSON → User object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'],
      email: json['email'] ?? '',
      phone: json['phone'],
      profileImg: json['profileImg'],
      role: json['role'] ?? 'user',
      active: json['active'] ?? true,
      token: json['token'], // expect token in response (optional)
    );
  }

  // Convert User object → JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'slug': slug,
      'email': email,
      'phone': phone,
      'profileImg': profileImg,
      'role': role,
      'active': active,
      'token': token,
    };
  }
}
