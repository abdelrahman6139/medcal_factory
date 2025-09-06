import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final wishlistProvider = StateNotifierProvider<WishlistNotifier, Set<String>>((
  ref,
) {
  return WishlistNotifier()..load();
});

class WishlistNotifier extends StateNotifier<Set<String>> {
  WishlistNotifier() : super(<String>{});
  static const _k = 'WISHLIST_IDS';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_k);
    if (raw == null) return;
    state = Set<String>.from(List<String>.from(jsonDecode(raw)));
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_k, jsonEncode(state.toList()));
  }

  Future<void> toggle(String id) async {
    final s = Set<String>.from(state);
    s.contains(id) ? s.remove(id) : s.add(id);
    state = s;
    await _persist();
  }
}
