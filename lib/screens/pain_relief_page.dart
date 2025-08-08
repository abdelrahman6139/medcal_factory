import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/sale_product_card.dart';
import '../constants/colors.dart';

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

    products = [
      Product(
        title: 'Panadol Extra',
        subtitle: '24 Tablets',
        price: '\$3.50',
        imageName: 'panadol_extra.jpeg',
        stock: 50,
      ),
      Product(
        title: 'Voltaren Gel',
        subtitle: '50g',
        price: '\$5.50',
        imageName: 'voltaren.png',
        stock: 40,
      ),
      Product(
        title: 'Panadol Cold & Flu',
        subtitle: '20 Tablets',
        price: '\$3.75',
        imageName: 'panadol_cold_flu.png',
        stock: 25,
      ),
    ];

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
                    return SaleProductCard(
                      product: product,
                      quantity: product.selectedQuantity,
                      onAdd: () {
                        setState(() {
                          if (product.selectedQuantity < product.stock) {
                            product.selectedQuantity++;
                          }
                        });
                      },
                      onRemove: () {
                        setState(() {
                          if (product.selectedQuantity > 0) {
                            product.selectedQuantity--;
                          }
                        });
                      },
                      onAddToCart: () {
                        if (product.selectedQuantity > 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${product.selectedQuantity} x ${product.title} added to cart!',
                              ),
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                        }
                      },
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
