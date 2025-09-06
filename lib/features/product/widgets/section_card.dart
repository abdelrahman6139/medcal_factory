// lib/features/product/presentation/widgets/section_card.dart
import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.fullBleed = false,
  });

  final String title;
  final Widget child;
  final bool fullBleed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // لما تكون fullBleed = true بنشيل الهوامش الجانبية
    final horizontal = fullBleed ? 0.0 : 16.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(horizontal, 0, horizontal, 12),
      child: Card(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Container(
          width: double.infinity,
          color: theme.colorScheme.surface, // خلفية ممتدة بالكامل
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              DefaultTextStyle(
                style: theme.textTheme.bodyMedium!,
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
