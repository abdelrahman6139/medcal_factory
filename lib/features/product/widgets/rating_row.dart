import 'package:flutter/material.dart';

class RatingRow extends StatelessWidget {
  const RatingRow({
    super.key,
    required this.avg,
    required this.count,
    required this.onRate,
  });
  final double avg;
  final int count;
  final VoidCallback onRate;

  @override
  Widget build(BuildContext context) {
    final stars = List.generate(5, (i) {
      final idx = i + 1;
      final filled = avg >= idx;
      final half = !filled && avg >= (idx - .5);
      return Padding(
        padding: const EdgeInsets.only(right: 2),
        child: Icon(
          half ? Icons.star_half : (filled ? Icons.star : Icons.star_border),
          size: 20,
          color: Colors.amber,
        ),
      );
    });

    return Row(
      children: [
        ...stars,
        const SizedBox(width: 8),
        Text(avg > 0 ? avg.toStringAsFixed(1) : 'No rating'),
        const SizedBox(width: 6),
        Text(
          '($count)',
          style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: onRate,
          icon: const Icon(Icons.rate_review, size: 18),
          label: const Text('Rate'),
        ),
      ],
    );
  }
}
