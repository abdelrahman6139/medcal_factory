import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharma_app/features/cart/models/cart.dart';
import 'package:pharma_app/features/cart/services/cart_cache_services.dart';
import 'package:pharma_app/features/cart/state/cart_state.dart';

class CartNotifier extends StateNotifier<CartState> {
  final CartCacheService _cacheService;

  CartNotifier(this._cacheService) : super(const CartInitial());

  /// Load cart from cache
  Future<void> loadCart() async {
    state = const CartLoading();
    try {
      final cart = await _cacheService.getCart();
      if (cart != null) {
        state = CartSuccess(cart);
      } else {
        state = const CartError("No cached cart found");
      }
    } catch (e) {
      state = CartError("Failed to load cart: $e");
    }
  }

  /// Save cart to cache
  Future<void> saveCart(Cart cart) async {
    state = const CartLoading();
    try {
      await _cacheService.saveCart(cart);
      state = CartSuccess(cart);
    } catch (e) {
      state = CartError("Failed to save cart: $e");
    }
  }

  /// Clear cart
  Future<void> clearCart() async {
    state = const CartLoading();
    try {
      await _cacheService.clearCart();
      state = const CartInitial();
    } catch (e) {
      state = CartError("Failed to clear cart: $e");
    }
  }
}

/// Riverpod provider
final cartNotifierProvider =
StateNotifierProvider<CartNotifier, CartState>((ref) {
  final cacheService = CartCacheService();
  return CartNotifier(cacheService);
});
