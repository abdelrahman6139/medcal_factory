import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/sale_product_card.dart';
import '../constants/colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<int> quantities = List.filled(10, 0);

  List<Product> products = [
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
      stock: 14,
    ),
    Product(
      title: 'Bodrexin',
      subtitle: '5pcs',
      price: '\$5.99',
      oldPrice: '\$6.50',
      imageName: 'bodrexin.png',
      stock: 8,
    ),
  ];

  // ⬅️ هيلبر للتنقل على Shop بتاب معيّن
  void _goToShopTab(int tabIndex) {
    Navigator.pushReplacementNamed(
      context,
      '/app',
      arguments: {
        'index': 2, // تبويب Shop في الـ BottomNav
        'shopTab': tabIndex, // 0=All, 2=On Sale, 4=Popular
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSearchBar(),
          const SizedBox(height: 20),

          // SHOP NOW #1 -> Shop/All
          buildBanner(
            'assets/images/pills.png',
            AppColors.text.withOpacity(0.4),
            'ORDER MEDICINE ONLINE',
            'Fast delivery. Trusted products. Affordable prices.',
            () => _goToShopTab(0), // 👈 All
          ),

          const SizedBox(height: 16),

          // SHOP NOW #2 -> Shop/On Sale
          buildBanner(
            'assets/images/doctor.jpg',
            AppColors.text.withOpacity(0.3),
            'Up to 80% Off On Health Products',
            'Homeopathy, Ayurvedic,\nPersonal Care & More',
            () => _goToShopTab(2), // 👈 On Sale
          ),

          const SizedBox(height: 24),

          // See all -> Shop/Popular
          sectionTitle('Popular Product', goToShopTab: 4),
          buildHorizontalProductList(0, 5),

          const SizedBox(height: 24),

          // See all -> Shop/On Sale
          sectionTitle('Product on Sale', goToShopTab: 2),
          buildHorizontalProductList(5, 10),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
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
        ),
      ),
    );
  }

  Widget buildBanner(
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
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
              ),
              onPressed: onTap,
              child: const Text('SHOP NOW'),
            ),
          ],
        ),
      ),
    );
  }

  // ⬅️ تعدلناها عشان تستقبل تبويب وتروح له
  Widget sectionTitle(String title, {int? goToShopTab}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        InkWell(
          onTap: () => _goToShopTab(goToShopTab ?? 0),
          child: const Text(
            'See all',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildHorizontalProductList(int start, int end) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: end - start,
        itemBuilder: (context, index) {
          final productIndex = start + index;
          return SaleProductCard(
            product: products[productIndex],
            quantity: quantities[productIndex],
            onAdd: () => setState(() => quantities[productIndex]++),
            onRemove:
                () => setState(() {
                  if (quantities[productIndex] > 0) quantities[productIndex]--;
                }),
            onAddToCart: () {
              final product = products[productIndex];
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${product.title} added to cart!')),
              );
            },
          );
        },
      ),
    );
  }
}
