String? buildProductImageUrl(String? imageCover, String baseUrl) {
  if (imageCover == null || imageCover.isEmpty) return null;

  // كامل؟
  if (imageCover.startsWith('http://') || imageCover.startsWith('https://')) {
    return imageCover;
  }

  // قيم بايظة جايه من السيرفر
  if (imageCover.startsWith('undefined')) return null;

  // نسبي: "headphones-cover.jpg" أو "products/file.jpg"
  final clean = imageCover.replaceFirst(RegExp(r'^/*'), '');
  // السيرفر عندك بيخدّم من /uploads
  return '$baseUrl/uploads/products/$clean';
}
