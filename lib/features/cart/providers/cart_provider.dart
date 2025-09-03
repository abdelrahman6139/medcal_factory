import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// لو عندك لوجر:
import '../../../core/debug/logger.dart';

// لو عايز تضيف عن طريق Product نفسه:
import '../../product/models/product.dart';

const _kCartStorageKey = 'cart_v1';

class CartItem {
  final String id; // productId
  final String title;
  final double price;
  final String image; // URL أو اسم ملف
  final int qty;

  const CartItem({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
    required this.qty,
  });

  CartItem copyWith({int? qty}) => CartItem(
    id: id,
    title: title,
    price: price,
    image: image,
    qty: qty ?? this.qty,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'price': price,
    'image': image,
    'qty': qty,
  };

  factory CartItem.fromJson(Map<String, dynamic> j) => CartItem(
    id: j['id'] as String,
    title: j['title'] as String,
    price: (j['price'] as num).toDouble(),
    image: (j['image'] ?? '') as String,
    qty: j['qty'] as int,
  );
}

class CartState {
  final Map<String, CartItem> items; // productId -> CartItem

  const CartState({required this.items});

  int get totalQty => items.values.fold(0, (s, it) => s + it.qty);
  double get totalPrice =>
      items.values.fold(0.0, (s, it) => s + (it.price * it.qty));

  List<CartItem> get asList => items.values.toList();

  CartState copyWith({Map<String, CartItem>? items}) =>
      CartState(items: items ?? this.items);

  Map<String, dynamic> toJson() => {
    'items': items.values.map((e) => e.toJson()).toList(),
  };

  factory CartState.fromJson(Map<String, dynamic> j) {
    final list = (j['items'] as List<dynamic>? ?? []);
    final map = <String, CartItem>{};
    for (final x in list) {
      final it = CartItem.fromJson(Map<String, dynamic>.from(x));
      map[it.id] = it;
    }
    return CartState(items: map);
  }

  static const empty = CartState(items: {});
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(CartState.empty) {
    _init();
  }

  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kCartStorageKey);
      if (raw != null) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        final loaded = CartState.fromJson(decoded);
        state = loaded;
        L.d(
          'CART',
          'loaded from storage',
          data: {
            'items': state.items.length,
            'totalQty': state.totalQty,
            'totalPrice': state.totalPrice,
          },
        );
      } else {
        L.d('CART', 'storage empty');
      }
    } catch (e, st) {
      L.e('CART', 'load error', error: e, st: st);
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(state.toJson());
      await prefs.setString(_kCartStorageKey, raw);
      L.d(
        'CART',
        'persist',
        data: {
          'items': state.items.length,
          'totalQty': state.totalQty,
          'totalPrice': state.totalPrice,
        },
      );
    } catch (e, st) {
      L.e('CART', 'persist error', error: e, st: st);
    }
  }

  /// إضافة منتج بكمية معيّنة (يجمع لو موجود)
  Future<void> addItem({
    required String productId,
    required String title,
    required double price,
    String image = '',
    required int qty,
  }) async {
    if (qty <= 0) return;

    final current = Map<String, CartItem>.from(state.items);
    final exists = current[productId];
    final newQty = (exists?.qty ?? 0) + qty;
    current[productId] = CartItem(
      id: productId,
      title: title,
      price: price,
      image: image,
      qty: newQty,
    );

    state = state.copyWith(items: current);
    L.d(
      'CART',
      'addItem',
      data: {'id': productId, 'qty': qty, 'newQty': newQty},
    );
    await _persist();
  }

  /// نسخة بتاخد Product مباشرة
  Future<void> addProduct(
    Product p,
    int qty, {
    String imageResolved = '',
  }) async {
    await addItem(
      productId: p.id,
      title: p.title,
      price: p.priceAfterDiscount ?? p.price,
      image: imageResolved.isNotEmpty ? imageResolved : (p.imageCover),
      qty: qty,
    );
  }

  Future<void> setQty(String productId, int qty) async {
    final current = Map<String, CartItem>.from(state.items);
    if (!current.containsKey(productId)) return;
    if (qty <= 0) {
      current.remove(productId);
    } else {
      current[productId] = current[productId]!.copyWith(qty: qty);
    }
    state = state.copyWith(items: current);
    L.d('CART', 'setQty', data: {'id': productId, 'qty': qty});
    await _persist();
  }

  Future<void> inc(String productId) async {
    final it = state.items[productId];
    if (it == null) return;
    await setQty(productId, it.qty + 1);
  }

  Future<void> dec(String productId) async {
    final it = state.items[productId];
    if (it == null) return;
    await setQty(productId, it.qty - 1);
  }

  Future<void> remove(String productId) async {
    final current = Map<String, CartItem>.from(state.items);
    current.remove(productId);
    state = state.copyWith(items: current);
    L.d('CART', 'remove', data: {'id': productId});
    await _persist();
  }

  Future<void> clear() async {
    state = CartState.empty;
    L.d('CART', 'clear');
    await _persist();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>(
  (ref) => CartNotifier(),
);
