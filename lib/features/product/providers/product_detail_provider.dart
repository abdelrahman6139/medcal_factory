import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../../cart/providers/cart_provider.dart';

/// حالة بسيطة للصفحة: كمية + عمليات
class ProductDetailState {
  final int qty;
  const ProductDetailState({this.qty = 1});

  ProductDetailState copyWith({int? qty}) =>
      ProductDetailState(qty: qty ?? this.qty);
}

class ProductDetailController extends StateNotifier<ProductDetailState> {
  final Ref ref;
  final Product product;

  ProductDetailController(this.ref, this.product)
    : super(const ProductDetailState());

  void inc() {
    if (state.qty < product.quantity) {
      state = state.copyWith(qty: state.qty + 1);
    }
  }

  void dec() {
    if (state.qty > 1) {
      state = state.copyWith(qty: state.qty - 1);
    }
  }

  bool get canAdd =>
      product.quantity > 0 && state.qty > 0 && state.qty <= product.quantity;

  Future<void> addToCart() async {
    if (!canAdd) return;
    final cart = ref.read(cartProvider.notifier);
    await cart.addProduct(product, state.qty);
  }
}

/// provider منشئ حسب الـ product
final productDetailControllerProvider = StateNotifierProvider.family<
  ProductDetailController,
  ProductDetailState,
  Product
>((ref, product) => ProductDetailController(ref, product));
