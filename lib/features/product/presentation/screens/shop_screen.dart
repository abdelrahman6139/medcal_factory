// lib/features/product/presentation/screens/shop_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pharma_app/constants/colors.dart';
import '../../widgets/product_card.dart';
import '../../models/product.dart';

// ✅ لو عندك index.dart بيصدّر الـ productListProvider خليه
import 'package:pharma_app/features/product/providers/index.dart';
// ⬇️ لو المسار مختلف عندك استخدم: '../../providers/quantity_provider.dart'
import '../state/quantity_notifier.dart';

// الكارت (يحفظ في SharedPreferences)
import '../../../cart/providers/cart_provider.dart';

// لوجر موحّد (بدّله بـ print لو مش مستخدمه)
import '../../../../core/debug/logger.dart';

class ShopScreen extends ConsumerStatefulWidget {
  final int initialTab;
  const ShopScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  final TextEditingController _searchC = TextEditingController();
  String _query = '';

  List<Product> _filter(List<Product> all) {
    if (_query.isEmpty) return all;
    final q = _query.toLowerCase();
    final filtered =
        all.where((p) => p.title.toLowerCase().contains(q)).toList();
    L.d(
      'SHOP',
      'filter results',
      data: {'query': _query, 'count': filtered.length},
    );
    return filtered;
  }

  @override
  void initState() {
    super.initState();
    L.d('SHOP', 'initState()');
  }

  @override
  void dispose() {
    L.d('SHOP', 'dispose() — clear search controller');
    _searchC.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    L.d('SHOP', 'onRefresh() -> start');
    try {
      await ref.read(productListProvider.notifier).refresh();
      L.d('SHOP', 'onRefresh() -> success');
    } catch (e, st) {
      L.e('SHOP', 'onRefresh() -> error', error: e, st: st);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Refresh failed')));
      }
    }
  }

  Future<void> _debugSnapshot() async {
    final asyncProducts = ref.read(productListProvider);
    final qtyMap = ref.read(productQuantityProvider);
    final cartState = ref.read(cartProvider);
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().toList()..sort();

    L.d(
      'DBG',
      'products snapshot',
      data: {
        'isLoading': asyncProducts.isLoading,
        'hasError': asyncProducts.hasError,
        'count': asyncProducts.hasValue ? asyncProducts.value!.length : null,
      },
    );
    L.d('DBG', 'quantities snapshot', data: qtyMap);
    L.d(
      'DBG',
      'cart snapshot',
      data: {
        'items': cartState.items.length,
        'totalQty': cartState.totalQty,
        'totalPrice': cartState.totalPrice,
      },
    );
    L.d('DBG', 'prefs keys', data: {'keys': keys});

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Debug snapshot printed to console')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncProducts = ref.watch(productListProvider);
    final qtyMap = ref.watch(productQuantityProvider);
    final qtyCtl = ref.read(productQuantityProvider.notifier);
    final cart = ref.read(cartProvider.notifier);

    // لوج سريع لحالة الـ providers كل build
    L.d(
      'SHOP',
      'build()',
      data: {
        'asyncProducts': {
          'loading': asyncProducts.isLoading,
          'hasError': asyncProducts.hasError,
          'hasValue': asyncProducts.hasValue,
          'count': asyncProducts.hasValue ? asyncProducts.value!.length : null,
        },
        'qtyMapSize': qtyMap.length,
      },
    );

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _debugSnapshot,
        child: const Icon(Icons.bug_report),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6)],
            ),
            child: TextField(
              controller: _searchC,
              onChanged: (v) {
                setState(() => _query = v);
                L.d('SHOP', 'search changed', data: {'query': v});
              },
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search products...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
            ),
          ),

          // Grid / Loading / Error
          Expanded(
            child: asyncProducts.when(
              loading: () {
                L.d('SHOP', 'state = loading');
                return const Center(child: CircularProgressIndicator());
              },
              error: (err, st) {
                L.e('SHOP', 'state = error', error: err, st: st);
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Error: $err',
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed:
                            () =>
                                ref
                                    .read(productListProvider.notifier)
                                    .refresh(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              },
              data: (list) {
                L.d('SHOP', 'state = data', data: {'count': list.length});
                final products = _filter(list);

                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child:
                      products.isEmpty
                          ? ListView(
                            children: const [
                              SizedBox(height: 220),
                              Center(child: Text('No products found')),
                            ],
                          )
                          : GridView.builder(
                            padding: const EdgeInsets.all(12),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: 0.70,
                                ),
                            itemCount: products.length,
                            itemBuilder: (context, i) {
                              final p = products[i];
                              final qty = qtyMap[p.id] ?? 0;

                              return ProductCard(
                                product: p,
                                quantity: qty,
                                onAdd: () {
                                  L.d(
                                    'QTY',
                                    'inc',
                                    data: {
                                      'id': p.id,
                                      'from': qty,
                                      'max': p.quantity,
                                    },
                                  );
                                  qtyCtl.increment(p.id, maxQty: p.quantity);
                                },
                                onRemove: () {
                                  L.d(
                                    'QTY',
                                    'dec',
                                    data: {'id': p.id, 'from': qty},
                                  );
                                  qtyCtl.decrement(p.id);
                                },
                                onAddToCart: () async {
                                  final picked = qtyCtl.getQty(p.id);
                                  L.d(
                                    'CART',
                                    'add-to-cart pressed',
                                    data: {
                                      'id': p.id,
                                      'title': p.title,
                                      'qty': picked,
                                    },
                                  );

                                  if (picked <= 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('اختار كمية الأول'),
                                      ),
                                    );
                                    return;
                                  }

                                  try {
                                    // لو عندك resolve للصورة (backend بيرجع اسم ملف مش URL)،
                                    // ممكن تمرّره في imageResolved.
                                    await cart.addProduct(
                                      p,
                                      picked /*, imageResolved: fullUrlIfNeeded */,
                                    );

                                    // صفّر الكمية المختارة بعد الحفظ
                                    qtyCtl.reset(p.id);

                                    // Feedback للمستخدم
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Added ${p.title} × $picked',
                                        ),
                                      ),
                                    );
                                  } catch (e, st) {
                                    L.e(
                                      'CART',
                                      'add-to-cart error',
                                      error: e,
                                      st: st,
                                    );
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Failed to add to cart'),
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
