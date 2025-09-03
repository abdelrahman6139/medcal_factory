import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharma_app/constants/colors.dart';
import '../../models/product.dart';
import 'package:pharma_app/features/product/providers/index.dart';
import '../../providers/core_providers.dart';

class ProductDetailsScreen extends ConsumerWidget {
  final String productId;
  const ProductDetailsScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncP = ref.watch(productDetailProvider(productId));
    final baseUrl = ref.watch(baseUrlProvider); // لبناء رابط الصورة عند توفرها

    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: asyncP.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (e, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Error: $e', style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed:
                        () =>
                            ref
                                .read(productDetailProvider(productId).notifier)
                                .refresh(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
        data: (Product p) {
          // محاولة عرض صورة لو موجودة لاحقًا
          String? imageUrl;
          if (p.imageCover.isNotEmpty) {
            // السيرفر بيخدم uploads/ كـ static: http://10.0.2.2:5000/uploads/products/<file>
            imageUrl = '$baseUrl/uploads/products/${p.imageCover}';
          }

          return RefreshIndicator(
            onRefresh:
                () =>
                    ref
                        .read(productDetailProvider(productId).notifier)
                        .refresh(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: AppColors.shadow, blurRadius: 6),
                      ],
                      image:
                          imageUrl != null
                              ? DecorationImage(
                                image: NetworkImage(imageUrl),
                                fit: BoxFit.cover,
                              )
                              : null,
                    ),
                    child:
                        imageUrl == null
                            ? const Center(
                              child: Icon(Icons.image_not_supported),
                            )
                            : null,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  p.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${p.priceAfterDiscount ?? p.price} EGP',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (p.priceAfterDiscount != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '${p.price} EGP',
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                if (p.category != null)
                  Text(
                    'Category: ${p.category!.name}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                const SizedBox(height: 12),
                Text(
                  p.description,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 20),

                // (لسه مش هنفعل الكارت)
                // Placeholder لأزرار مستقبلية لو حبيت
                // ElevatedButton(
                //   onPressed: () {},
                //   child: const Text('Add to cart'),
                // ),
              ],
            ),
          );
        },
      ),
    );
  }
}
