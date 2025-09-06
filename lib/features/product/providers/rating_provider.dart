import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../product/presentation/screens/shop_screen.dart' show baseUrl;

final ratingSenderProvider = Provider<RatingSender>((ref) => RatingSender());

class RatingSender {
  Future<void> rateProduct({
    required String productId,
    required double rating,
  }) async {
    // عدّل المسار حسب الباكإند
    final url = Uri.parse('$baseUrl/api/v1/products/$productId/rate');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'rating': rating}),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Failed with ${res.statusCode}');
    }
  }
}
