// lib/features/product/cache/product_cache.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../../../core/debug/logger.dart';

class ProductCache {
  static const _kListKey = 'cache_products_list';
  static const _kListTsKey = 'cache_products_list_ts';
  static const _kItemPrefix = 'cache_product_'; // + id
  static const _kItemTsPrefix = 'cache_product_ts_';

  final SharedPreferences prefs;
  ProductCache(this.prefs);

  // -------- List cache --------
  Future<void> saveProducts(List<Product> list) async {
    final payload = list.map((p) => p.toJson()).toList();
    await prefs.setString(_kListKey, jsonEncode(payload));
    await prefs.setInt(_kListTsKey, DateTime.now().millisecondsSinceEpoch);

    L.d('CACHE', 'saveProducts()', data: {'count': list.length});
  }

  List<Product>? loadProducts() {
    final raw = prefs.getString(_kListKey);
    if (raw == null) {
      L.d('CACHE', 'loadProducts() -> null');
      return null;
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    final list =
        decoded
            .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
            .toList();

    L.d('CACHE', 'loadProducts() -> success', data: {'count': list.length});
    return list;
  }

  bool isListFresh(Duration ttl) {
    final ts = prefs.getInt(_kListTsKey);
    if (ts == null) {
      L.d('CACHE', 'isListFresh() -> false (no ts)');
      return false;
    }
    final age = DateTime.now().millisecondsSinceEpoch - ts;
    final fresh = age <= ttl.inMilliseconds;

    L.d(
      'CACHE',
      'isListFresh()',
      data: {'ttlMs': ttl.inMilliseconds, 'ageMs': age, 'fresh': fresh},
    );
    return fresh;
  }

  // -------- Single item cache --------
  Future<void> saveProduct(Product p) async {
    await prefs.setString('$_kItemPrefix${p.id}', jsonEncode(p.toJson()));
    await prefs.setInt(
      '$_kItemTsPrefix${p.id}',
      DateTime.now().millisecondsSinceEpoch,
    );

    L.d('CACHE', 'saveProduct()', data: {'id': p.id, 'title': p.title});
  }

  Product? loadProduct(String id) {
    final raw = prefs.getString('$_kItemPrefix$id');
    if (raw == null) {
      L.d('CACHE', 'loadProduct($id) -> null');
      return null;
    }

    final product = Product.fromJson(
      Map<String, dynamic>.from(jsonDecode(raw)),
    );
    L.d('CACHE', 'loadProduct($id) -> success', data: {'title': product.title});
    return product;
  }

  bool isProductFresh(String id, Duration ttl) {
    final ts = prefs.getInt('$_kItemTsPrefix$id');
    if (ts == null) {
      L.d('CACHE', 'isProductFresh($id) -> false (no ts)');
      return false;
    }
    final age = DateTime.now().millisecondsSinceEpoch - ts;
    final fresh = age <= ttl.inMilliseconds;

    L.d(
      'CACHE',
      'isProductFresh($id)',
      data: {'ttlMs': ttl.inMilliseconds, 'ageMs': age, 'fresh': fresh},
    );
    return fresh;
  }

  // -------- Clear all --------
  Future<void> clear() async {
    await prefs.remove(_kListKey);
    await prefs.remove(_kListTsKey);

    final keys = prefs.getKeys().toList();
    for (final k in keys) {
      if (k.startsWith(_kItemPrefix) || k.startsWith(_kItemTsPrefix)) {
        await prefs.remove(k);
      }
    }

    L.d('CACHE', 'clear() -> done');
  }

  // -------- Clear single item --------
  Future<void> clearProduct(String id) async {
    await prefs.remove('$_kItemPrefix$id');
    await prefs.remove('$_kItemTsPrefix$id');

    L.d('CACHE', 'clearProduct($id) -> done');
  }
}
