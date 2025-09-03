import 'package:flutter/material.dart';
import '../models/product.dart';
import '../../../constants/colors.dart';
import '../../../widgets/quantity_control.dart';
import '../../../core/utils/image_url.dart'; // 👈

class ProductCard extends StatelessWidget {
  final Product product;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback? onAddToCart;

  // لو حابب تدي baseUrl من برا، خليه ثابت هنا (emulator)
  static const String _baseUrl = 'http://10.0.2.2:5000';

  const ProductCard({
    Key? key,
    required this.product,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
    this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final coverUrl = buildProductImageUrl(product.imageCover, _baseUrl);

    Widget imageWidget;
    if (coverUrl == null) {
      // Placeholder لو مفيش لينك صالح
      imageWidget = Container(
        height: 70,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFFEFEFEF),
        ),
        child: const Center(child: Icon(Icons.image_not_supported, size: 28)),
      );
    } else {
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          coverUrl,
          height: 70,
          width: double.infinity,
          fit: BoxFit.cover,
          // لو السيرفر راجع 400 أو الصورة وقعت → مايبقاش فيه Exception
          errorBuilder:
              (_, __, ___) => Container(
                height: 70,
                color: const Color(0xFFEFEFEF),
                child: const Center(child: Icon(Icons.broken_image, size: 28)),
              ),
        ),
      );
    }

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(10),
      constraints: const BoxConstraints(minHeight: 230),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Image + quantity badge
          Stack(
            children: [
              imageWidget, // 👈 بدل NetworkImage القديم
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                  child: Text(
                    'x$quantity',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Product details
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${product.quantity} available',
                style: const TextStyle(fontSize: 12, color: AppColors.textGray),
              ),
              const SizedBox(height: 6),
              Text(
                '\$${product.price}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 6),
              QuantityControl(
                quantity: quantity,
                onAdd: onAdd,
                onRemove: onRemove,
              ),
            ],
          ),

          // Add to cart button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onAddToCart,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 6),
                textStyle: const TextStyle(fontSize: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Add to Cart'),
            ),
          ),
        ],
      ),
    );
  }
}
