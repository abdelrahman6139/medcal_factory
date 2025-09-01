import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/product_repository.dart';
import 'service_provider.dart';
import 'cache_provider.dart';

final productRepositoryProvider = FutureProvider<ProductRepository>((
  ref,
) async {
  final svc = ref.watch(productServiceProvider);
  final cache = await ref.watch(productCacheProvider.future);
  return ProductRepository(svc, cache);
});
