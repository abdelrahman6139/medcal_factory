// lib/models/address_model.dart
class Address {
  final String id;
  final String details;
  final String phone;
  final String city;
  final String postalCode;

  Address({
    required this.id,
    required this.details,
    required this.phone,
    required this.city,
    required this.postalCode,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['_id'],
      details: json['details'],
      phone: json['phone'],
      city: json['city'],
      postalCode: json['postalCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "details": details,
      "phone": phone,
      "city": city,
      "postalCode": postalCode,
    };
  }
}
