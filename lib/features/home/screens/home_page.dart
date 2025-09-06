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

import '../../product/presentation/state/quantity_notifier.dart';
import '../../cart/providers/cart_provider.dart';

// ⬅️ مهم: عشان نفتح صفحة التفاصيل
import '../../product/presentation/screens/product_details_screen.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  static const String _baseUrl = 'http://10.0.2.2:5000';
  final List<Product> _all = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = await AuthCache(prefs).getAccessToken();
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
      L.e('HOME', 'error', error: e, st: st);
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Product _withResolvedImageUrl(Product p) {
    bool isUrl(String s) => s.startsWith('http://') || s.startsWith('https://');
    if (p.imageCover.isEmpty || isUrl(p.imageCover)) return p;
    final full = '$_baseUrl/uploads/products/${p.imageCover}';
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

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
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

    final qtyMap = ref.watch(productQuantityProvider);
    final qtyCtl = ref.read(productQuantityProvider.notifier);
    final cart = ref.read(cartProvider.notifier);

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        children: [
          _SearchBar(),
          const SizedBox(height: 20),

          _PromoBanner(
            image: 'assets/images/pills.png',
            overlay: AppColors.text.withValues(alpha: .40),
            title: 'ORDER MEDICINE ONLINE',
            subtitle: 'Fast delivery. Trusted products. Affordable prices.',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _PromoBanner(
            image: 'assets/images/doctor.jpg',
            overlay: AppColors.text.withValues(alpha: .30),
            title: 'Up to 80% Off On Health Products',
            subtitle: 'Homeopathy, Ayurvedic,\nPersonal Care & More',
            onTap: () {},
          ),

          const SizedBox(height: 20),
          const _SectionTitle('All Products'),
          const SizedBox(height: 8),

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
                        final p = _withResolvedImageUrl(_all[i]);
                        final q = qtyMap[p.id] ?? 0;

                        return ProductCard(
                          product: p,
                          quantity: q,
                          onAdd:
                              () => qtyCtl.increment(p.id, maxQty: p.quantity),
                          onRemove: () => qtyCtl.decrement(p.id),
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
                              await cart.addProduct(p, picked);
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Added ${p.title} x$picked'),
                                ),
                              );
                              qtyCtl.reset(p.id);
                            } catch (_) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to add to cart'),
                                ),
                              );
                            }
                          },

                          // 👇 نفس سلوك الـShop
                          onTap: () {
                            final heroTag = 'product-${p.id}-cover';
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => ProductDetailsScreen(
                                      product: p,
                                      heroTag: heroTag,
                                    ),
                              ),
                            );
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

/* ====== صغار ====== */

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner({
    required this.image,
    required this.overlay,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final String image;
  final Color overlay;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: overlay,
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
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );
  }
}
