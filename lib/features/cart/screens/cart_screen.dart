import 'package:flutter/material.dart';
import 'package:pharma_app/constants/colors.dart';
import 'package:pharma_app/features/product/models/product.dart';
import 'package:pharma_app/features/payment/screens/checkout_page.dart';
import ''; // ✅ علشان نستخدم Product

class CartItem {
  final String id;
  final String title;
  final double price;
  final String image; // اسم ملف الصورة داخل assets/images
  int qty;

  CartItem({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
    this.qty = 1,
  });
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // ✅ أمثلة على المنتجات الموجودة في الكارت
  final List<CartItem> _items = [
    CartItem(
      id: 'p1',
      title: 'Panadol Extra 500mg',
      price: 55,
      image: 'panadol_extra.jpeg',
    ),
    CartItem(
      id: 'p2',
      title: 'Betadine 50ml',
      price: 80,
      image: 'betadine.png',
    ),
    CartItem(
      id: 'p3',
      title: 'OBH Combi 75ml',
      price: 120,
      image: 'obh_combi.png',
    ),
  ];

  double get _subtotal => _items.fold(0, (sum, i) => sum + (i.price * i.qty));
  double get _delivery => _items.isEmpty ? 0 : 20;
  double get _total => _subtotal + _delivery;

  void _incQty(int i) => setState(() => _items[i].qty++);
  void _decQty(int i) => setState(() {
    if (_items[i].qty > 1) _items[i].qty--;
  });
  void _remove(int i) => setState(() => _items.removeAt(i));

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Your Cart',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // ✅ قائمة المنتجات
        if (_items.isEmpty)
          Expanded(
            child: Center(
              child: Text(
                'Cart is empty',
                style: TextStyle(color: AppColors.subtitle, fontSize: 16),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final it = _items[i];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ✅ صورة المنتج
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/images/${it.image}',
                          height: 56,
                          width: 56,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // ✅ العنوان والسعر
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              it.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${it.price.toStringAsFixed(2)} EGP',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ✅ كنترول الكمية
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => _decQty(i),
                            icon: const Icon(Icons.remove_circle_outline),
                            color: AppColors.primary,
                            tooltip: 'Decrease',
                          ),
                          Text(
                            '${it.qty}',
                            style: const TextStyle(
                              color: AppColors.text,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          IconButton(
                            onPressed: () => _incQty(i),
                            icon: const Icon(Icons.add_circle_outline),
                            color: AppColors.primary,
                            tooltip: 'Increase',
                          ),
                        ],
                      ),

                      // ✅ حذف
                      IconButton(
                        onPressed: () => _remove(i),
                        icon: const Icon(Icons.delete_outline),
                        color: AppColors.danger,
                        tooltip: 'Remove',
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

        const SizedBox(height: 12),

        // ✅ الملخص والإجمالي
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6)],
          ),
          child: Column(
            children: [
              _rowTotal('Subtotal', _subtotal),
              const SizedBox(height: 6),
              _rowTotal('Delivery', _delivery),
              const Divider(height: 18),
              _rowTotal('Total', _total, bold: true),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.lock),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed:
                      _items.isEmpty
                          ? null
                          : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => CheckoutPage(
                                      cartProducts:
                                          _items.map((e) {
                                            return Product(
                                              id: e.id,
                                              title: e.title,
                                              slug: e.title.toLowerCase().replaceAll(" ", "-"), // simple slug
                                              description: "No description", // placeholder
                                              quantity: e.qty,
                                              sold: 0,
                                              price: e.price,
                                              imageCover: e.image,
                                              category: null, // or a proper Category object if you have one
                                            );
                                          }).toList(),
                                    ),
                              ),
                            );
                          },
                  label: const Text(
                    'Checkout',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _rowTotal(String label, double value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.subtitle,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          '${value.toStringAsFixed(2)} EGP',
          style: TextStyle(
            color: AppColors.text,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
