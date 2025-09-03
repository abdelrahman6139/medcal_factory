import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/product_service.dart';
import 'core_providers.dart';
import '../../../core/debug/logger.dart';

final productServiceProvider = Provider<ProductService>((ref) {
  final base = ref.watch(baseUrlProvider);
  final token = ref.watch(tokenProvider);

  if (token.isEmpty) {
    L.d('AUTH', 'token is empty — API calls may fail (401)');
  } else {
    L.d('AUTH', 'token present', data: {'len': token.length});
  }
  return ProductService(baseUrl: base, token: token);
});
