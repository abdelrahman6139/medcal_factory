import 'package:pharma_app/features/cart/models/cart.dart';

/// Base class for Cart states
abstract class CartState {
  const CartState();
}

/// Initial state (nothing loaded yet)
class CartInitial extends CartState {
  const CartInitial();
}

/// Loading state (fetching data, saving, etc.)
class CartLoading extends CartState {
  const CartLoading();
}

/// Success state (cart loaded successfully)
class CartSuccess extends CartState {
  final Cart cart;
  const CartSuccess(this.cart);
}

/// Error state (something went wrong)
class CartError extends CartState {
  final String message;
  const CartError(this.message);
}
