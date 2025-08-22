import '../models/product.dart';
import '../services/product_service.dart';

class ProductRepository {
  final ProductService service;

  ProductRepository(this.service);

  Future<List<Product>> fetchProducts() async {
    return await service.getProducts();
  }

  Future<Product> fetchProduct(String id) async {
    return await service.getProduct(id);
  }
}
