class Product {
  final String title;
  final String subtitle;
  final String price;
  final String? oldPrice;
  final String imageName;
  final int stock; // ← ده المخزون
  int selectedQuantity; // ← الكمية اللي المستخدم اختارها

  Product({
    required this.title,
    required this.subtitle,
    required this.price,
    this.oldPrice,
    required this.imageName,
    required this.stock,
    this.selectedQuantity = 0,
  });
}
