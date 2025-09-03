import 'package:flutter_riverpod/flutter_riverpod.dart';

/// state = Map<productId, quantity>
class ProductQuantityNotifier extends StateNotifier<Map<String, int>> {
  ProductQuantityNotifier() : super(const {});

  void increment(String productId, {int maxQty = 1 << 30}) {
    final current = state[productId] ?? 0;
    final next = (current + 1) <= maxQty ? current + 1 : current;
    if (next != current) {
      state = {...state, productId: next};
    }
  }

  void decrement(String productId) {
    final current = state[productId] ?? 0;
    final next = current > 0 ? current - 1 : 0;
    if (next != current) {
      if (next == 0) {
        final m = Map<String, int>.from(state)..remove(productId);
        state = m;
      } else {
        state = {...state, productId: next};
      }
    }
  }

  int getQty(String productId) => state[productId] ?? 0;

  void reset(String productId) {
    if (state.containsKey(productId)) {
      final m = Map<String, int>.from(state)..remove(productId);
      state = m;
    }
  }

  void clearAll() => state = const {};
}

final productQuantityProvider =
    StateNotifierProvider<ProductQuantityNotifier, Map<String, int>>(
      (ref) => ProductQuantityNotifier(),
    );
