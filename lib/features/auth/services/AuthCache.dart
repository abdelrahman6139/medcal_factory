import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pharma_app/features/auth/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthCache {
  final FlutterSecureStorage _secure = const FlutterSecureStorage();
  final SharedPreferences _prefs;

  AuthCache(this._prefs);

  // Save tokens
  Future<void> saveTokens(String access, String refresh) async {
    await _secure.write(key: 'accessToken', value: access);
    await _secure.write(key: 'refreshToken', value: refresh);
  }

  // Load tokens
  Future<String?> getAccessToken() => _secure.read(key: 'accessToken');
  Future<String?> getRefreshToken() => _secure.read(key: 'refreshToken');

  // Save user data
  Future<void> saveUser(User user) async {
    _prefs.setString('user', jsonEncode(user.toJson()));
  }

  User? getUser() {
    final json = _prefs.getString('user');
    return json != null ? User.fromJson(jsonDecode(json)) : null;
  }

  // Clear all
  Future<void> clear() async {
    await _secure.deleteAll();
    await _prefs.clear();
  }
}
