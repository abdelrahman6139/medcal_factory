import 'dart:math' as math;
import 'package:dio/dio.dart';
import '../models/product.dart';
import '../../../core/debug/logger.dart'; // ← اللوجر اللي عملناه

class ProductService {
  final Dio _dio;

  ProductService({required String baseUrl, required String token})
    : _dio = Dio(
        BaseOptions(
          baseUrl: '$baseUrl/api/v1',
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          validateStatus: (c) => c != null && c >= 200 && c < 500,
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final start = DateTime.now().millisecondsSinceEpoch;
          options.extra['__start'] = start;
          L.d(
            'HTTP →',
            '${options.method} ${options.uri}',
            data: {
              'headers': options.headers,
              'query': options.queryParameters,
              if (options.data != null) 'body': options.data,
            },
          );
          handler.next(options);
        },
        onResponse: (res, handler) {
          final start = res.requestOptions.extra['__start'] as int?;
          final durMs =
              start == null
                  ? null
                  : (DateTime.now().millisecondsSinceEpoch - start);
          // لو الرد كبير، خلّيك مختصر: مفاتيح/الطول
          final shape =
              res.data is Map
                  ? {'keys': (res.data as Map).keys.toList()}
                  : (res.data is List
                      ? {'len': (res.data as List).length}
                      : {'type': '${res.data.runtimeType}'});
          L.d(
            'HTTP ←',
            'status=${res.statusCode}  (${durMs ?? '?'} ms)',
            data: shape,
          );
          handler.next(res);
        },
        onError: (e, handler) {
          L.e(
            'HTTP ✖',
            '${e.requestOptions.method} ${e.requestOptions.uri}',
            error: e,
            st: e.stackTrace,
          );

          if (e.response?.data != null) {
            final shape =
                e.response!.data is Map
                    ? {'keys': (e.response!.data as Map).keys.toList()}
                    : (e.response!.data is List
                        ? {'len': (e.response!.data as List).length}
                        : {'type': '${e.response!.data.runtimeType}'});
            L.d('HTTP ✖ body', 'shape', data: shape);
          }
          handler.next(e);
        },
      ),
    );
  }

  // Helper صغير للّوج
  String _preview(dynamic data, [int maxChars = 400]) {
    final s = (data is String) ? data : data.toString();
    final n = math.min(s.length, maxChars);
    return s.substring(0, n);
  }

  Future<List<Product>> getProducts({int limit = 20}) async {
    try {
      final res = await _dio.get(
        '/products',
        queryParameters: {'limit': limit},
      );

      // DEBUG
      // ignore: avoid_print
      print('GET /products => ${res.statusCode} (${res.data.runtimeType})');
      // ignore: avoid_print
      print('Body preview: ${_preview(res.data)}');

      // أخطاء أوث/سيرفر برسالة أوضح
      if (res.statusCode == 401 || res.statusCode == 403) {
        throw Exception('Unauthorized: invalid/expired token.');
      }
      if (res.statusCode == 429) {
        throw Exception('Rate limited. Try again later.');
      }
      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}: ${_preview(res.data)}');
      }

      final body = res.data;

      // 1) Array مباشر
      if (body is List) {
        return body
            .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      // 2) { data: [ ... ] }
      if (body is Map<String, dynamic>) {
        final data = body['data'];

        if (data is List) {
          return data
              .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }

        // 3) { data: { docs: [ ... ] } }
        if (data is Map && data['docs'] is List) {
          final docs = List<Map<String, dynamic>>.from(
            (data['docs'] as List).map((e) => Map<String, dynamic>.from(e)),
          );
          return docs.map(Product.fromJson).toList();
        }

        // 4) { products: [ ... ] }
        if (body['products'] is List) {
          final list = List<Map<String, dynamic>>.from(
            (body['products'] as List).map((e) => Map<String, dynamic>.from(e)),
          );
          return list.map(Product.fromJson).toList();
        }

        // 5) { results: N, data: { data: [ ... ] } }
        if (data is Map && data['data'] is List) {
          final list = List<Map<String, dynamic>>.from(
            (data['data'] as List).map((e) => Map<String, dynamic>.from(e)),
          );
          return list.map(Product.fromJson).toList();
        }

        // 6) { items: [ ... ] }
        if (body['items'] is List) {
          final list = List<Map<String, dynamic>>.from(
            (body['items'] as List).map((e) => Map<String, dynamic>.from(e)),
          );
          return list.map(Product.fromJson).toList();
        }
      }

      throw Exception('Unexpected products response shape');
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message);
    }
  }

  Future<Product> getProduct(String id) async {
    try {
      final res = await _dio.get('/products/$id');

      if (res.statusCode == 401 || res.statusCode == 403) {
        throw Exception('Unauthorized: invalid/expired token.');
      }
      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}: ${_preview(res.data)}');
      }

      if (res.data is Map<String, dynamic>) {
        final body = res.data as Map<String, dynamic>;
        final map =
            (body['data'] is Map<String, dynamic>)
                ? Map<String, dynamic>.from(body['data'])
                : Map<String, dynamic>.from(body);
        return Product.fromJson(map);
      }

      throw Exception('Unexpected product response shape');
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message);
    }
  }
}
