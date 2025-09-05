// lib/features/auth/services/AuthCache.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pharma_app/features/auth/models/user.dart';

class AuthCache {
  final FlutterSecureStorage _secure;
  final SharedPreferences _prefs;
  const AuthCache._(this._secure, this._prefs);

  static Future<AuthCache> create() async {
    final prefs = await SharedPreferences.getInstance();
    return AuthCache._(const FlutterSecureStorage(), prefs);
  }

  // Tokens
  Future<void> saveTokens(String access, [String? refresh]) async {
    await _secure.write(key: 'accessToken', value: access);
    if (refresh != null) {
      await _secure.write(key: 'refreshToken', value: refresh);
    }
  }

  Future<String?> getAccessToken() => _secure.read(key: 'accessToken');
  Future<String?> getRefreshToken() => _secure.read(key: 'refreshToken');

  Future<void> clearTokens() async {
    await _secure.delete(key: 'accessToken');
    await _secure.delete(key: 'refreshToken');
  }

  // User
  Future<void> saveUser(User user) async {
    await _prefs.setString('user', jsonEncode(user.toJson()));
  }

  User? getUser() {
    final raw = _prefs.getString('user');
    if (raw == null) return null;
    return User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> clearUser() async {
    await _prefs.remove('user');
  }

  // All
  Future<void> clearAll() async {
    await _secure.deleteAll();
    await _prefs.clear();
  }

  Future<bool> hasSession() async {
    final t = await getAccessToken();
    return t != null && t.isNotEmpty && getUser() != null;
  }
}
