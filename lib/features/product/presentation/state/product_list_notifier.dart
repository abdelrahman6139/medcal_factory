import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/product.dart';
import '../../repositories/product_repository.dart';
import '../../providers/repository_provider.dart';
import '../../../../core/debug/logger.dart';

class ProductListNotifier extends AsyncNotifier<List<Product>> {
  static const Duration ttl = Duration(minutes: 10);
  late final ProductRepository _repo;

  @override
  Future<List<Product>> build() async {
    L.d('PROVIDER', 'ProductListNotifier.build()');
    _repo = await ref.watch(productRepositoryProvider.future);
    state = const AsyncLoading();
    try {
      final list = await _repo.fetchProducts(ttl: ttl);
      L.d('PROVIDER', 'loaded list', data: {'count': list.length});
      return list;
    } catch (e, st) {
      L.e('PROVIDER', 'build failed', error: e, st: st);
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> refresh() async {
    L.d('PROVIDER', 'refresh()');
    final prev = state.valueOrNull;
    state = const AsyncLoading();
    try {
      final list = await _repo.fetchProducts(forceRefresh: true, ttl: ttl);
      L.d('PROVIDER', 'refresh done', data: {'count': list.length});
      state = AsyncData(list);
    } catch (e, st) {
      L.e('PROVIDER', 'refresh error', error: e, st: st);
      state = prev != null ? AsyncData(prev) : AsyncError(e, st);
    }
  }
}

final productListProvider =
    AsyncNotifierProvider<ProductListNotifier, List<Product>>(
      () => ProductListNotifier(),
    );
