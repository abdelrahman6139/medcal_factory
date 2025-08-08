import 'package:flutter/material.dart';
import '../models/product.dart';
import '../constants/colors.dart';
import '../widgets/sale_product_card.dart';

class ShopScreen extends StatefulWidget {
  final int
  initialTab; // 👈 تاب مبدئي: 0 All, 1 New, 2 On Sale, 3 Low Stock, 4 Popular
  const ShopScreen({super.key, this.initialTab = 0});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final TextEditingController _searchC = TextEditingController();

  // كل المنتجات
  final List<Product> _allProducts = [
    Product(
      title: 'Panadol Extra',
      subtitle: '24 Tablets',
      price: '\$3.50',
      imageName: 'panadol_extra.jpeg',
      stock: 30,
    ),
    Product(
      title: 'Betadine',
      subtitle: '50ml',
      price: '\$6.99',
      oldPrice: '\$8.00',
      imageName: 'betadine.png',
      stock: 20,
    ),
    Product(
      title: 'OBH Combi',
      subtitle: '75ml',
      price: '\$9.99',
      imageName: 'obh_combi.png',
      stock: 15,
    ),
    Product(
      title: 'Fucidin Cream',
      subtitle: '15g',
      price: '\$6.00',
      imageName: 'fucidin.png',
      stock: 10,
    ),
    Product(
      title: 'Voltaren Gel',
      subtitle: '50g',
      price: '\$5.50',
      imageName: 'voltaren.png',
      stock: 12,
    ),
    Product(
      title: 'Gaviscon',
      subtitle: '150ml',
      price: '\$7.00',
      oldPrice: '\$9.00',
      imageName: 'gaviscon.jpeg',
      stock: 25,
    ),
    Product(
      title: 'Panadol Cold & Flu',
      subtitle: '20 Tablets',
      price: '\$3.75',
      imageName: 'panadol_cold_flu.png',
      stock: 18,
    ),
    Product(
      title: 'Amoxil 500mg',
      subtitle: 'Capsules',
      price: '\$4.00',
      imageName: 'amoxil.png',
      stock: 22,
    ),
    Product(
      title: 'Cetirizine',
      subtitle: '10mg',
      price: '\$2.50',
      imageName: 'cetirizine.png',
      stock: 9,
    ),
    Product(
      title: 'Bodrexin',
      subtitle: '5pcs',
      price: '\$5.99',
      oldPrice: '\$6.50',
      imageName: 'bodrexin.png',
      stock: 6,
    ),
  ];

  // مؤقت: New & Popular
  final Set<String> _newTitles = {
    'Panadol Cold & Flu',
    'Amoxil 500mg',
    'Voltaren Gel',
  };
  final Set<String> _popularTitles = {
    'Panadol Extra',
    'Betadine',
    'OBH Combi',
    'Fucidin Cream',
  };

  late final Map<String, int> _qtyByTitle;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _qtyByTitle = {for (final p in _allProducts) p.title: 0};
  }

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  List<Product> _filterForTab(int tabIndex) {
    // 0 All, 1 New, 2 On Sale, 3 Low Stock, 4 Popular
    List<Product> base = switch (tabIndex) {
      0 => _allProducts,
      1 => _allProducts.where((p) => _newTitles.contains(p.title)).toList(),
      2 => _allProducts.where((p) => p.oldPrice != null).toList(),
      3 => _allProducts.where((p) => (p.stock ?? 0) <= 10).toList(),
      4 => _allProducts.where((p) => _popularTitles.contains(p.title)).toList(),
      _ => _allProducts,
    };

    if (_query.trim().isEmpty) return base;

    final q = _query.toLowerCase();
    return base
        .where(
          (p) =>
              p.title.toLowerCase().contains(q) ||
              p.subtitle.toLowerCase().contains(q),
        )
        .toList();
  }

  void _addQty(Product p) {
    final stock = p.stock ?? 9999;
    final cur = _qtyByTitle[p.title] ?? 0;
    if (cur < stock) {
      setState(() => _qtyByTitle[p.title] = cur + 1);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No more stock available')));
    }
  }

  void _removeQty(Product p) {
    final cur = _qtyByTitle[p.title] ?? 0;
    if (cur > 0) setState(() => _qtyByTitle[p.title] = cur - 1);
  }

  void _addToCart(Product p) {
    final q = _qtyByTitle[p.title] ?? 0;
    if (q == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select quantity first')),
      );
      return;
    }
    // TODO: اربط بالـ Cart الحقيقي
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${p.title} x$q added to cart')));
    setState(() => _qtyByTitle[p.title] = 0);
  }

  @override
  Widget build(BuildContext context) {
    final int safeInitial = widget.initialTab.clamp(0, 4); // 👈 تأمين الرينج

    return DefaultTabController(
      length: 5,
      initialIndex: safeInitial, // 👈 افتح على التاب اللي جاي من الهوم
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search
          Container(
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
          const SizedBox(height: 12),

          // Tabs
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 4)],
            ),
            child: const TabBar(
              isScrollable: true,
              labelPadding: EdgeInsets.symmetric(horizontal: 16),
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.subtitle,
              tabs: [
                Tab(text: 'All'),
                Tab(text: 'New'),
                Tab(text: 'On Sale'),
                Tab(text: 'Low Stock'),
                Tab(text: 'Popular'),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Content
          Expanded(
            child: TabBarView(
              physics: const BouncingScrollPhysics(),
              children: List.generate(5, (tabIndex) {
                final items = _filterForTab(tabIndex);

                if (items.isEmpty) {
                  return const Center(
                    child: Text(
                      'No products here.',
                      style: TextStyle(color: AppColors.subtitle),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.only(bottom: 8, top: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.70,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final p = items[i];
                    final qty = _qtyByTitle[p.title] ?? 0;
                    return SaleProductCard(
                      product: p,
                      quantity: qty,
                      onAdd: () => _addQty(p),
                      onRemove: () => _removeQty(p),
                      onAddToCart: () => _addToCart(p),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
