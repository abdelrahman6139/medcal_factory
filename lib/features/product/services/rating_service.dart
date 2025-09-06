import 'package:http/http.dart' as http;

class RatingService {
  final String baseUrl;
  RatingService(this.baseUrl);

  Future<void> rateProduct({
    required String productId,
    required double rating,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/v1/products/$productId/ratings'),
      body: {'rating': rating.toString()},
    );
    if (res.statusCode >= 300) {
      throw Exception('Failed to rate product: ${res.statusCode}');
    }
  }
}
