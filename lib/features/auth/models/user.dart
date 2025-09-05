// lib/features/auth/models/user.dart
class User {
  final String id;
  final String name;
  final String? slug;
  final String email;
  final String? phone;
  final String? role;
  final String? profileImg;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.name,
    this.slug,
    required this.email,
    this.phone,
    this.role,
    this.profileImg,
    this.createdAt,
    this.updatedAt,
  });

  User copyWith({
    String? id,
    String? name,
    String? slug,
    String? email,
    String? phone,
    String? role,
    String? profileImg,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      profileImg: profileImg ?? this.profileImg,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    final id = (json['_id'] ?? json['id'] ?? '').toString();
    return User(
      id: id,
      name: (json['name'] ?? '').toString(),
      slug: json['slug']?.toString(),
      email: (json['email'] ?? '').toString(),
      phone: json['phone']?.toString(),
      role: json['role']?.toString(),
      profileImg: json['profileImg']?.toString() ?? json['profile_image']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'email': email,
        'phone': phone,
        'role': role,
        'profileImg': profileImg,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };
}
