// lib/features/home/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/colors.dart';
import '../../product/models/product.dart';
import '../../product/widgets/product_card.dart';
import '../../product/services/product_service.dart';
import '../../auth/services/auth_cache.dart';
import '../../../core/debug/logger.dart';

// ✅ Provider بتاع الكميات (لو مسارك مختلف: غيّر السطر ده)
import '../../product/presentation/state/quantity_notifier.dart';

// ✅ Provider بتاع الكارت (persisted في SharedPreferences)
import '../../cart/providers/cart_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  static const String _baseUrl = 'http://10.0.2.2:5000'; // Emulator
  final List<Product> _all = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    L.d('HOME', 'init');
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final auth = AuthCache(prefs);
      final token = await auth.getAccessToken();

      if (token == null || token.isEmpty) {
        throw Exception('No access token found. Please login first.');
      }

      final service = ProductService(baseUrl: _baseUrl, token: token);

      L.d(
        'HTTP →',
        'GET /products',
        data: {
          'baseUrl': _baseUrl,
          'headers': {'Authorization': 'Bearer ${token.substring(0, 8)}...'},
          'query': {'limit': 20},
        },
      );

      final products = await service.getProducts(limit: 20);

      L.d('HTTP ←', 'loaded products', data: {'count': products.length});

      _all
        ..clear()
        ..addAll(products);

      if (!mounted) return;
      setState(() => _loading = false);
    } catch (e, st) {
      L.e('HOME', 'error', error: e, st: st, data: {'msg': e.toString()});
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // بديل واضح لـ withOpacity (deprec.):
  Color _withAlpha(Color c, double alpha) =>
      c.withValues(alpha: alpha.clamp(0.0, 1.0));

  Future<void> _debugSnapshot() async {
    // كميات + كارت + مفاتيح SharedPreferences
    final qtyMap = ref.read(productQuantityProvider);
    final cartState = ref.read(cartProvider);
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().toList()..sort();

    L.d(
      'DBG',
      'home snapshot',
      data: {
        'productsCount': _all.length,
        'qtyMapSize': qtyMap.length,
        'cart': {
          'items': cartState.items.length,
          'totalQty': cartState.totalQty,
          'totalPrice': cartState.totalPrice,
        },
        'prefsKeys': keys,
      },
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Home snapshot printed to console')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('حصل خطأ:\n$_error', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    // ✅ Riverpod quantities
    final qtyMap = ref.watch(productQuantityProvider);
    final qtyCtl = ref.read(productQuantityProvider.notifier);

    // ✅ Cart notifier (هيعمل persist تلقائيًا)
    final cart = ref.read(cartProvider.notifier);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _debugSnapshot,
        child: const Icon(Icons.bug_report),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 20),

            // Banners
            _buildBanner(
              'assets/images/pills.png',
              _withAlpha(AppColors.text, 0.40),
              'ORDER MEDICINE ONLINE',
              'Fast delivery. Trusted products. Affordable prices.',
              () {
                // TODO: اربطها بالـ Shop لو عايز
              },
            ),
            const SizedBox(height: 16),
            _buildBanner(
              'assets/images/doctor.jpg',
              _withAlpha(AppColors.text, 0.30),
              'Up to 80% Off On Health Products',
              'Homeopathy, Ayurvedic,\nPersonal Care & More',
              () {},
            ),

            const SizedBox(height: 24),
            _sectionTitle('All Products'),
            const SizedBox(height: 8),

            // قائمة أفقية بالمنتجات
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.38,
              child:
                  _all.isEmpty
                      ? const Center(child: Text('مفيش منتجات حالياً'))
                      : ListView.separated(
                        padding: const EdgeInsets.only(right: 4),
                        scrollDirection: Axis.horizontal,
                        itemCount: _all.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, i) {
                          final p = _all[i];
                          final fixed = _withResolvedImageUrl(p);
                          final q = qtyMap[p.id] ?? 0;

                          return ProductCard(
                            product: fixed,
                            quantity: q,
                            onAdd: () {
                              L.d(
                                'QTY',
                                'home +',
                                data: {
                                  'id': p.id,
                                  'from': q,
                                  'max': p.quantity,
                                },
                              );
                              qtyCtl.increment(p.id, maxQty: p.quantity);
                            },
                            onRemove: () {
                              L.d(
                                'QTY',
                                'home -',
                                data: {'id': p.id, 'from': q},
                              );
                              qtyCtl.decrement(p.id);
                            },
                            onAddToCart: () async {
                              final picked = qtyMap[p.id] ?? 0;
                              if (picked <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('اختار كمية الأول'),
                                  ),
                                );
                                return;
                              }

                              try {
                                // 🧺 حفظ للكارت + persist في SharedPreferences (داخل cartProvider)
                                await cart.addProduct(fixed, picked);

                                // Debug + feedback
                                L.d(
                                  'CART',
                                  'home add-to-cart',
                                  data: {
                                    'id': p.id,
                                    'title': p.title,
                                    'qty': picked,
                                  },
                                );
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Added ${p.title} x$picked'),
                                  ),
                                );

                                // صفّر الكمية بعد الإضافة
                                qtyCtl.reset(p.id);
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
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ==== Widgets ==== //
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6)],
      ),
      child: const TextField(
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search),
          hintText: 'Search for medicine...',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildBanner(
    String imagePath,
    Color overlayColor,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: overlayColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.text,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
              ),
              onPressed: onTap,
              child: const Text('SHOP NOW'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(),
      ],
    );
  }

  /// بعض الـ backends بترجع `imageCover` كإسم ملف مش URL كامل.
  /// لو مش URL، بنبني رابط `uploads/products/<file>`.
  Product _withResolvedImageUrl(Product p) {
    bool looksLikeUrl(String s) =>
        s.startsWith('http://') || s.startsWith('https://');

    final cover = p.imageCover;
    if (cover.isEmpty || looksLikeUrl(cover)) return p;

    final full = '$_baseUrl/uploads/products/$cover';
    return Product(
      id: p.id,
      title: p.title,
      slug: p.slug,
      description: p.description,
      quantity: p.quantity,
      sold: p.sold,
      price: p.price,
      priceAfterDiscount: p.priceAfterDiscount,
      colors: p.colors,
      imageCover: full,
      images: p.images,
      category: p.category,
    );
  }
}
