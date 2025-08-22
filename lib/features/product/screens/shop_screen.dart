import 'package:flutter/material.dart';
import 'package:pharma_app/constants/colors.dart';
import 'package:pharma_app/features/product/widgets/product_card.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';
import '../services/product_service.dart';

class ShopScreen extends StatefulWidget {
  final int initialTab;

  const ShopScreen({super.key, this.initialTab = 0});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final TextEditingController _searchC = TextEditingController();

  late final ProductRepository _repo;
  List<Product> _allProducts = [];
  bool _isLoading = true;
  String? _error;
  String _query = '';
  String initialToken =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4OTZhOTRlYWYwNDQ0ZmU5OTFmODJjNiIsImlhdCI6MTc1NDcyMTAxMywiZXhwIjoxNzU1MzI1ODEzfQ.yZCm5TYUXVcdkJ4X7MZpwcB-RBmmXks1ZNyMprj6lSA";

  @override
  void initState() {
    super.initState();
    // In real app: inject token dynamically
    final service = ProductService(initialToken);
    _repo = ProductRepository(service);
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final products = await _repo.fetchProducts();
      setState(() {
        _allProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Product> _filterProducts() {
    if (_query.isEmpty) return _allProducts;
    final q = _query.toLowerCase();
    return _allProducts.where((p) => p.title.toLowerCase().contains(q)).toList();
  }

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text("Error: $_error", style: const TextStyle(color: Colors.red)),
      );
    }

    final products = _filterProducts();

    return Column(
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
            onChanged: (v) => setState(() => _query = v),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search products...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
          ),
        ),

        // Grid of products
        Expanded(
          child: products.isEmpty
              ? const Center(child: Text("No products found"))
              : GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.70,
            ),
            itemCount: products.length,
            itemBuilder: (context, i) {
              final p = products[i];
              return ProductCard(
                product: p, quantity: 0, onAdd: () {  }, onRemove: () {  },
              );
            },
          ),
        ),
      ],
    );
  }
}
