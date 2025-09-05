// lib/features/product/presentation/screens/shop_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pharma_app/constants/colors.dart';
import '../../widgets/product_card.dart';
import '../../models/product.dart';
import '../../models/category.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pharma_app/features/product/providers/index.dart';
import '../state/quantity_notifier.dart';
import '../../../cart/providers/cart_provider.dart';
import '../../../../core/debug/logger.dart';

const baseUrl = 'http://10.0.2.2:5000';

final categoryListProvider = FutureProvider<List<Category>>((ref) async {
  final res = await http.get(Uri.parse('$baseUrl/api/v1/categories'));

  if (res.statusCode != 200) {
    throw Exception('Failed to load categories: ${res.statusCode}');
  }

  final json = jsonDecode(res.body);
  final list =
      (json['data'] as List).map((e) {
        final category = Category.fromJson(e);
        debugPrint('🟦 CATEGORY: ${category.name} | Image: ${category.image}');
        return category;
      }).toList();

  return list;
});

class ShopScreen extends ConsumerStatefulWidget {
  final int initialTab;
  const ShopScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('CACHED_PRODUCTS');
      await prefs.remove('CACHED_PRODUCTS_TIMESTAMP');

      // وبعد ما نمسح الكاش نعمل تحديث
      await ref.read(productListProvider.notifier).refresh();
    });
  }

  final TextEditingController _searchC = TextEditingController();
  String _query = '';
  String? _selectedCategoryId;

  List<Product> _filter(List<Product> all) {
    final q = _query.toLowerCase();
    return all.where((p) {
      final matchQuery = p.title.toLowerCase().contains(q);
      final matchCategory =
          _selectedCategoryId == null || p.category?.id == _selectedCategoryId;

      return matchQuery && matchCategory;
    }).toList();
  }

  Future<void> _onRefresh() async {
    await ref.read(productListProvider.notifier).refresh();
  }

  Future<void> _debugSnapshot() async {
    final asyncProducts = ref.read(productListProvider);
    final qtyMap = ref.read(productQuantityProvider);
    final cartState = ref.read(cartProvider);
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().toList()..sort();
    L.d('DBG', 'products', data: {'count': asyncProducts.value?.length});
    L.d('DBG', 'quantities', data: qtyMap);
    L.d('DBG', 'cart', data: cartState.toJson());
    L.d('DBG', 'prefs keys', data: {'keys': keys});
  }

  Widget _buildCategoryBar() {
    final asyncCategories = ref.watch(categoryListProvider);

    return asyncCategories.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Text('Error: $err'),
      data:
          (categories) => SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = _selectedCategoryId == cat.id;

                final imageUrl = cat.image;
                final isValidImage =
                    imageUrl != null && imageUrl.startsWith('http');

                debugPrint(
                  '🟨 Category: ${cat.name} | image: $imageUrl | isValid: $isValidImage',
                );

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategoryId = (isSelected ? null : cat.id);
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 80,
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  isSelected
                                      ? AppColors.primary
                                      : Colors.grey.shade300,
                              width: 2,
                            ),
                            image:
                                isValidImage
                                    ? DecorationImage(
                                      image: NetworkImage(imageUrl!),
                                      fit: BoxFit.cover,
                                      onError: (e, s) {
                                        debugPrint(
                                          '🟥 Error loading image: $imageUrl',
                                        );
                                      },
                                    )
                                    : null,
                            color: const Color(0xFFEFEFEF),
                          ),
                          child:
                              !isValidImage
                                  ? const Icon(Icons.broken_image, size: 28)
                                  : null,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          cat.name,
                          style: const TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncProducts = ref.watch(productListProvider);
    final qtyMap = ref.watch(productQuantityProvider);
    final qtyCtl = ref.read(productQuantityProvider.notifier);
    final cart = ref.read(cartProvider.notifier);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _debugSnapshot,
        child: const Icon(Icons.bug_report),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6)],
            ),
            child: TextField(
              controller: _searchC,
              onChanged: (v) => setState(() => _query = v),
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
          _buildCategoryBar(),
          Expanded(
            child: asyncProducts.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (products) {
                final filtered = _filter(products);
                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child:
                      filtered.isEmpty
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
                            itemCount: filtered.length,
                            itemBuilder: (context, i) {
                              final p = filtered[i];
                              final qty = qtyMap[p.id] ?? 0;
                              return ProductCard(
                                product: p,
                                quantity: qty,
                                onAdd:
                                    () => qtyCtl.increment(
                                      p.id,
                                      maxQty: p.quantity,
                                    ),
                                onRemove: () => qtyCtl.decrement(p.id),
                                onAddToCart: () async {
                                  final picked = qtyCtl.getQty(p.id);
                                  if (picked <= 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('اختار كمية الأول'),
                                      ),
                                    );
                                    return;
                                  }
                                  await cart.addProduct(p, picked);
                                  qtyCtl.reset(p.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Added ${p.title} × $picked',
                                      ),
                                    ),
                                  );
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
