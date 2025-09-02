
// lib/features/cart/services/cart_cache_service.dart
import 'dart:convert';
import 'package:pharma_app/features/cart/models/cart.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service class responsible for caching cart data locally.
/// Uses [SharedPreferences] to persist cart JSON.
class CartCacheService {
  static const String _cartKey = 'cached_cart';

  /// Saves the given [Cart] object into cache.
  Future<void> saveCart(Cart cart) async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = jsonEncode(cart.toJson());
    await prefs.setString(_cartKey, cartJson);
  }

  /// Retrieves the cached [Cart] object, or `null` if not found.
  Future<Cart?> getCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString(_cartKey);
    if (cartJson == null) return null;

    final Map<String, dynamic> decoded = jsonDecode(cartJson);
    return Cart.fromJson(decoded);
  }

  /// Clears the cached cart.
  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }
}
