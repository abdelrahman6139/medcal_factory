// lib/widgets/section_separator.dart
import 'package:flutter/material.dart';

class SectionSeparator extends StatelessWidget {
  const SectionSeparator({super.key, this.height = 16});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      color: Theme.of(context).scaffoldBackgroundColor,
    );
  }
}
