// lib/widgets/hpad.dart
import 'package:flutter/material.dart';

class HPad extends StatelessWidget {
  const HPad({super.key, required this.child, this.padding});
  final Widget child;
  final double? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding ?? 16),
      child: child,
    );
  }
}
