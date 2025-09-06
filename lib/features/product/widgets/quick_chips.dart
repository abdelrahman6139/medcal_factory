import 'package:flutter/material.dart';

class QuickChips extends StatelessWidget {
  const QuickChips({super.key, required this.items});
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          items.map((t) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: theme.dividerColor.withOpacity(.4)),
              ),
              child: Text(t, style: const TextStyle(fontSize: 12)),
            );
          }).toList(),
    );
  }
}
