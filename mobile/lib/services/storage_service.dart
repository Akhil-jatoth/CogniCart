import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class StorageService {
  static const String _userKey = 'cognicart_logged_user';
  static const String _nameKey = 'cognicart_user_display_name';
  static const String _recentSearchesKey = 'cognicart_recent_searches';
  static const String _cartKey = 'cognicart_offline_cart';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static String? getUser() => _prefs?.getString(_userKey);
  static String? getUsername() => getUser();
  static bool isLoggedIn() => getUser() != null && getUser()!.isNotEmpty;

  static Future<void> setUser(String? username) async {
    if (username == null || username.isEmpty) {
      await _prefs?.remove(_userKey);
      await _prefs?.remove(_nameKey);
    } else {
      await _prefs?.setString(_userKey, username);
      if (_prefs?.getString(_nameKey) == null) {
        await _prefs?.setString(_nameKey, username.split('@')[0]);
      }
    }
  }

  static Future<void> logout() => setUser(null);

  static String getDisplayName() {
    final name = _prefs?.getString(_nameKey);
    if (name != null && name.isNotEmpty) return name;
    final user = getUser();
    if (user != null && user.contains('@')) return user.split('@')[0];
    return 'Shopper';
  }

  static Future<void> setDisplayName(String name) async {
    await _prefs?.setString(_nameKey, name);
  }

  static List<String> getRecentSearches() {
    return _prefs?.getStringList(_recentSearchesKey) ?? ['iPhone 15', 'Laptop', 'Headphones', 'Smart Watch'];
  }

  static Future<void> addRecentSearch(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return;
    final current = getRecentSearches().where((s) => s.toLowerCase() != clean.toLowerCase()).toList();
    current.insert(0, clean);
    if (current.length > 15) {
      current.removeLast();
    }
    await _prefs?.setStringList(_recentSearchesKey, current);
  }

  static Future<void> clearRecentSearches() async {
    await _prefs?.remove(_recentSearchesKey);
  }

  static List<Product> getLocalCart() {
    final raw = _prefs?.getString(_cartKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((item) => Product.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveLocalCart(List<Product> cart) async {
    final list = cart.map((p) => p.toJson()).toList();
    await _prefs?.setString(_cartKey, jsonEncode(list));
  }
}
