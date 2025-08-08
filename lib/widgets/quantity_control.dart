import 'package:flutter/material.dart';
import '../constants/colors.dart';

class QuantityControl extends StatelessWidget {
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const QuantityControl({
    Key? key,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: quantity > 0 ? onRemove : null,
          child: Icon(
            Icons.remove_circle_outline,
            size: 20,
            color:
                quantity > 0
                    ? AppColors.textGray
                    : AppColors.textGray.withOpacity(0.3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$quantity',
          style: const TextStyle(fontSize: 14, color: AppColors.text),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: onAdd,
          child: const Icon(
            Icons.add_circle,
            size: 20,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
