import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/product.dart';
import '../../repositories/product_repository.dart';
import '../../providers/repository_provider.dart';
import '../../../../core/debug/logger.dart';

class ProductDetailNotifier extends FamilyAsyncNotifier<Product, String> {
  static const Duration ttl = Duration(minutes: 10);
  late final ProductRepository _repo;

  @override
  Future<Product> build(String id) async {
    L.d('PROVIDER', 'ProductDetail.build($id)');
    _repo = await ref.watch(productRepositoryProvider.future);
    final p = await _repo.fetchProduct(id, ttl: ttl);
    L.d('PROVIDER', 'detail loaded', data: {'id': p.id, 'title': p.title});
    return p;
  }

  Future<void> refresh() async {
    final id = arg;
    L.d('PROVIDER', 'detail refresh($id)');
    final prev = state.valueOrNull;
    try {
      state = const AsyncLoading();
      final p = await _repo.fetchProduct(id, forceRefresh: true, ttl: ttl);
      state = AsyncData(p);
    } catch (e, st) {
      L.e('PROVIDER', 'detail refresh error', error: e, st: st);
      state = prev != null ? AsyncData(prev) : AsyncError(e, st);
    }
  }
}

final productDetailProvider =
    AsyncNotifierProviderFamily<ProductDetailNotifier, Product, String>(
      ProductDetailNotifier.new,
    );
