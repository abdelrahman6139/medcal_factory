import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../widgets/product_card.dart';
import '../../../../constants/colors.dart';

class PainReliefPage extends StatefulWidget {
  const PainReliefPage({super.key});

  @override
  State<PainReliefPage> createState() => _PainReliefPageState();
}

class _PainReliefPageState extends State<PainReliefPage> {
  late List<Product> products;
  List<Product> filteredProducts = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    products = [];

    filteredProducts = List.from(products);
  }

  void _filterSearch(String query) {
    setState(() {
      filteredProducts =
          products
              .where(
                (product) =>
                    product.title.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 1,
        title: const Text(
          'Pain Relief',
          style: TextStyle(color: AppColors.text),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ✅ Search bar
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: AppColors.shadow, blurRadius: 6),
                  ],
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: _filterSearch,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search products...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),

              // ✅ Products Grid
              Expanded(
                child: GridView.builder(
                  itemCount: filteredProducts.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.6,
                  ),
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return ProductCard(
                      product: product,
                      quantity: 0,
                      onAdd: () {},
                      onRemove: () {},
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
