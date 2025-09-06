// lib/features/product/presentation/widgets/full_bleed_text_section.dart
import 'package:flutter/material.dart';
import 'section_card.dart';
import 'section_separator.dart';

class FullBleedTextSection extends StatelessWidget {
  const FullBleedTextSection({
    super.key,
    required this.title,
    required this.text,
    this.showSeparatorBelow = true,
  });

  final String title;
  final String text;
  final bool showSeparatorBelow;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      SectionCard(title: title, child: Text(text), fullBleed: true),
    ];
    if (showSeparatorBelow) {
      children.add(const SectionSeparator());
    }
    return Column(children: children);
  }
}
