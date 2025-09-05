String? buildProductImageUrl(String? imageCover, String baseUrl) {
  if (imageCover == null || imageCover.isEmpty) return null;

  // لو الرابط جاهز وكامل
  if (imageCover.startsWith('http://') || imageCover.startsWith('https://')) {
    // استبدل localhost بـ 10.0.2.2 عشان emulator
    return imageCover.replaceFirst('localhost', '10.0.2.2');
  }

  // قيم بايظة
  if (imageCover.startsWith('undefined')) return null;

  final clean = imageCover.replaceFirst(RegExp(r'^/*'), '');
  return '$baseUrl/uploads/products/$clean';
}
