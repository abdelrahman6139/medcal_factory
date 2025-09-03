// lib/features/product/repositories/product_repository.dart
//import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../services/product_cache.dart';
import '../../../core/debug/logger.dart';

class ProductRepository {
  final ProductService service;
  final ProductCache cache;

  ProductRepository(this.service, this.cache);

  // TTL افتراضي: 10 دقايق
  static const Duration _defaultTtl = Duration(minutes: 10);

  // إرجاع الكاش فورًا إن كان Fresh، وإلا الشبكة
  // SWR: تقدر تعمل تحديث صامت بعد الإرجاع لو حابب (تحت)
  Future<List<Product>> fetchProducts({
    bool forceRefresh = false,
    Duration ttl = _defaultTtl,
  }) async {
    final local = cache.loadProducts();
    final fresh = cache.isListFresh(ttl);
    L.d(
      'REPO',
      'fetchProducts()',
      data: {
        'forceRefresh': forceRefresh,
        'hasLocal': local != null,
        'fresh': fresh,
      },
    );

    if (!forceRefresh && local != null && fresh) {
      L.d('REPO', 'return LOCAL', data: {'count': local.length});

      return local;
    }

    try {
      final remote = await service.getProducts();
      L.d('REPO', 'return REMOTE', data: {'count': remote.length});

      // حدّث الكاش
      await cache.saveProducts(remote);
      return remote;
    } catch (e, st) {
      L.e('REPO', 'remote failed, fallback local', error: e as Object?, st: st);

      // لو الشبكة فشلِت وعندنا كاش قديم — رجّعه بدل ما نكسر الـ UI
      if (local != null) return local;
      rethrow;
    }
  }

  // fetch single with cache
  Future<Product> fetchProduct(
    String id, {
    bool forceRefresh = false,
    Duration ttl = _defaultTtl,
  }) async {
    final local = cache.loadProduct(id);
    final fresh = cache.isProductFresh(id, ttl);
    L.d(
      'REPO',
      'fetchProduct($id)',
      data: {
        'forceRefresh': forceRefresh,
        'hasLocal': local != null,
        'fresh': fresh,
      },
    );

    if (!forceRefresh && local != null && fresh) {
      L.d('REPO', 'return LOCAL item', data: {'id': id});

      return local;
    }

    try {
      final remote = await service.getProduct(id);
      L.d(
        'REPO',
        'return REMOTE item',
        data: {'id': id, 'title': remote.title},
      );

      await cache.saveProduct(remote);
      return remote;
    } catch (e, st) {
      L.e('REPO', 'remote failed, fallback local', error: e as Object?, st: st);

      if (local != null) return local;
      rethrow;
    }
  }
}
