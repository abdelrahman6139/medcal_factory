import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/product_cache.dart';

import 'prefs_provider.dart';

final productCacheProvider = FutureProvider<ProductCache>((ref) async {
  final prefs = await ref.watch(sharedPrefsProvider.future);
  return ProductCache(prefs);
});
