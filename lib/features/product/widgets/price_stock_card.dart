import 'package:flutter/material.dart';
import '../../../../constants/colors.dart';

class PriceStockCard extends StatelessWidget {
  const PriceStockCard({
    super.key,
    required this.price,
    this.sale,
    required this.inStock,
    required this.qty,
  });

  final double price;
  final double? sale;
  final bool inStock;
  final int qty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDiscount = sale != null && sale! < price;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: const Offset(0, 6),
            color: Colors.black.withOpacity(.06),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          return Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    hasDiscount
                        ? '\$${sale!.toStringAsFixed(2)}'
                        : '\$${price.toStringAsFixed(2)}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (hasDiscount)
                    Text(
                      '\$${price.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        decoration: TextDecoration.lineThrough,
                        color: theme.colorScheme.onSurface.withOpacity(0.55),
                      ),
                    ),
                  if (hasDiscount) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '-${(((price - sale!) / price) * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: c.maxWidth * .6),
                child: Row(
                  children: [
                    Icon(
                      inStock ? Icons.check_circle : Icons.cancel,
                      color: inStock ? Colors.green : Colors.redAccent,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      inStock ? 'In stock ($qty available)' : 'Out of stock',
                      style: TextStyle(
                        color: inStock ? Colors.green : Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
