// lib/services/review_service.dart
import 'package:dio/dio.dart';
import '../models/review.dart';

class ReviewService {
  late Dio _dio;

  ReviewService(String token) {
    _dio = Dio(
      BaseOptions(
        baseUrl: "http://localhost:5000/api/v1",
        headers: {"Authorization": "Bearer $token"},
      ),
    );
  }

  // Get all reviews (optionally by productId)
  Future<List<Review>> getReviews({String? productId}) async {
    final url = productId != null ? "/products/$productId/reviews" : "/reviews";
    final response = await _dio.get(url);
    final reviews = (response.data['data'] as List)
        .map((item) => Review.fromJson(item))
        .toList();
    return reviews;
  }

  // Get a specific review by ID
  Future<Review> getReview(String reviewId) async {
    final response = await _dio.get("/reviews/$reviewId");
    return Review.fromJson(response.data['data']);
  }

  // Create review
  Future<Review> createReview({
    required String productId,
    double? ratings,
    String? title,
  }) async {
    final response = await _dio.post(
      "/reviews",
      data: {
        "product": productId,
        "ratings": ratings,
        "title": title,
      },
    );
    return Review.fromJson(response.data['data']);
  }

  // Update review
  Future<Review> updateReview({
    required String reviewId,
    double? ratings,
    String? title,
  }) async {
    final response = await _dio.put(
      "/reviews/$reviewId",
      data: {
        if (ratings != null) "ratings": ratings,
        if (title != null) "title": title,
      },
    );
    return Review.fromJson(response.data['data']);
  }

  // Delete review
  Future<void> deleteReview(String reviewId) async {
    await _dio.delete("/reviews/$reviewId");
  }
}
