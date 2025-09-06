// lib/features/product/presentation/screens/product_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/product.dart';
import '../../../../core/utils/base_url.dart';
import '../../../../core/utils/image_url.dart';
import '../../providers/product_detail_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/rating_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../widgets/gallery.dart';
import '../../widgets/price_stock_card.dart';
import '../../widgets/rating_row.dart';
import '../../widgets/quick_chips.dart';
import '../../widgets/bottom_bar.dart';
import '../../widgets/hpad.dart';
import '../../widgets/full_bleed_text_section.dart';

class ProductDetailsScreen extends ConsumerWidget {
  const ProductDetailsScreen({super.key, required this.product, this.heroTag});
  final Product product;
  final String? heroTag;

  double? _salePrice(Product p) => p.priceAfterDiscount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baseUrl = getBaseUrl();
    final coverUrl = buildProductImageUrl(product.imageCover, baseUrl);

    final controller = ref.watch(
      productDetailControllerProvider(product).notifier,
    );
    final state = ref.watch(productDetailControllerProvider(product));

    final price = product.price;
    final sale = _salePrice(product);
    final hasDiscount = sale != null && sale < price;
    final inStock = product.quantity > 0;

    final avg = product.ratingsAverage ?? 0.0;
    final count = product.ratingsQuantity ?? 0;

    return Scaffold(
      bottomNavigationBar: ProductBottomBar(
        qty: state.qty,
        onMinus: controller.dec,
        onPlus: controller.inc,
        onAddToCart:
            controller.canAdd
                ? () async {
                  await controller.addToCart();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added ${product.title} × ${state.qty}'),
                      ),
                    );
                  }
                }
                : null,
      ),
      body: CustomScrollView(
        slivers: [
          // ===== AppBar + Gallery =====
          SliverAppBar(
            pinned: true,
            expandedHeight: 320,
            // مهم: نخلي عرض الـ leading ثابت عشان الحسابات تكون متوقعة
            leadingWidth: 56,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Consumer(
                builder: (_, ref, __) {
                  final fav = ref.watch(wishlistProvider);
                  final isFav = fav.contains(product.id);
                  return IconButton(
                    tooltip:
                        isFav ? 'Remove from favorites' : 'Add to favorites',
                    onPressed: () async {
                      await ref
                          .read(wishlistProvider.notifier)
                          .toggle(product.id);
                      if (!context.mounted) return;
                      final nowFav = ref
                          .read(wishlistProvider)
                          .contains(product.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            nowFav
                                ? 'Added to favorites'
                                : 'Removed from favorites',
                          ),
                        ),
                      );
                    },
                    icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
                  );
                },
              ),
              IconButton(
                tooltip: 'Share',
                onPressed:
                    () => Share.share(
                      '${product.title} - \$${product.price.toStringAsFixed(2)}',
                    ),
                icon: const Icon(Icons.share),
              ),
            ],
            // FlexibleSpace مع padding ديناميكي حسب حالة الانهيار
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                // ارتفاع الـ Toolbar الفعلي (مع الـ status bar)
                final top = MediaQuery.of(context).padding.top;
                final toolbar = kToolbarHeight + top;
                // لما يوصل الارتفاع الحالي لقيمة قريبة من الـ toolbar، اعتبره Collapsed
                final isCollapsed = constraints.biggest.height <= toolbar + 8;

                // padding ديناميكي: لما ينهار نزود start و end
                final double startPad =
                    isCollapsed ? 72 : 16; // لتفادي تراكب زر الرجوع
                final double endPad =
                    isCollapsed ? 72 : 16; // لتفادي تراكب أيقونات actions

                return FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: EdgeInsetsDirectional.only(
                    start: startPad,
                    end: endPad,
                    bottom: 12,
                  ),
                  title: Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  background: ProductGallery(
                    imageUrl: coverUrl,
                    heroTag: heroTag ?? 'product-${product.id}-cover',
                  ),
                );
              },
            ),
          ),

          // ===== Body =====
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // عناصر بهوامش جانبية فقط
                HPad(
                  child: PriceStockCard(
                    price: price,
                    sale: hasDiscount ? sale : null,
                    inStock: inStock,
                    qty: product.quantity,
                  ),
                ),
                const SizedBox(height: 12),

                HPad(
                  child: RatingRow(
                    avg: avg,
                    count: count,
                    onRate: () => _openRateDialog(context, ref),
                  ),
                ),
                const SizedBox(height: 8),

                HPad(
                  child: QuickChips(
                    items: [
                      if (product.category?.name != null)
                        product.category!.name,
                      inStock ? 'In stock' : 'Out of stock',
                      'Max: ${product.quantity}',
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // سيكشنات full-bleed مع فواصل تلقائية بلون الخلفية
                ..._buildSections(product),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// يبني السيكشنات النصية كاملة مع فواصل اللون الافتراضي بين كل سيكشن
  List<Widget> _buildSections(Product p) {
    final data = <Map<String, String>>[
      if (p.description.trim().isNotEmpty)
        {'title': 'Description', 'text': p.description},
      if ((p.composition ?? '').trim().isNotEmpty)
        {'title': 'Composition', 'text': p.composition!},
      if ((p.indication ?? '').trim().isNotEmpty)
        {'title': 'Indication', 'text': p.indication!},
      if ((p.pharmacologicalActions ?? '').trim().isNotEmpty)
        {'title': 'Pharmacological Actions', 'text': p.pharmacologicalActions!},
      if ((p.dosage ?? '').trim().isNotEmpty)
        {'title': 'Dosage', 'text': p.dosage!},
      if ((p.warnings ?? '').trim().isNotEmpty)
        {'title': 'Warnings', 'text': p.warnings!},
    ];

    final widgets = <Widget>[];
    for (var i = 0; i < data.length; i++) {
      final it = data[i];
      widgets.add(
        FullBleedTextSection(
          title: it['title']!,
          text: it['text']!,
          showSeparatorBelow: i != data.length - 1, // آخر عنصر بدون فاصل
        ),
      );
    }
    return widgets;
  }

  Future<void> _openRateDialog(BuildContext context, WidgetRef ref) async {
    final sender = ref.read(ratingSenderProvider);
    double temp = 0;
    await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Rate this product'),
            content: StatefulBuilder(
              builder:
                  (_, setS) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (i) {
                      final idx = i + 1;
                      return IconButton(
                        onPressed: () => setS(() => temp = idx.toDouble()),
                        icon: Icon(
                          temp >= idx ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                      );
                    }),
                  ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed:
                    temp == 0
                        ? null
                        : () async {
                          try {
                            await sender.rateProduct(
                              productId: product.id,
                              rating: temp,
                            );
                            if (context.mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Thanks for rating!'),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Rating failed: $e')),
                              );
                            }
                          }
                        },
                child: const Text('Submit'),
              ),
            ],
          ),
    );
  }
}
