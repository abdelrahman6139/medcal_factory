import 'package:flutter/material.dart';

class ProductGallery extends StatelessWidget {
  const ProductGallery({super.key, required this.imageUrl, this.heroTag});

  final String? imageUrl;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final img =
        imageUrl == null
            ? Container(color: const Color(0xFFF4F4F4))
            : Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => Container(
                    color: const Color(0xFFEFEFEF),
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 48),
                    ),
                  ),
            );

    final content = Stack(
      fit: StackFit.expand,
      children: [
        img,
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(.35)],
            ),
          ),
        ),
      ],
    );

    if (heroTag == null) return content;
    return Hero(tag: heroTag!, child: content);
  }
}
