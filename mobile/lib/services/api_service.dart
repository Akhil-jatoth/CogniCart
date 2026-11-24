import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  // Use production Vercel deployment as default primary endpoint
  static const String baseUrl = 'https://cognicart-three.vercel.app/api';

  static const Duration timeoutDuration = Duration(seconds: 22);

  // ─── MULTI-STORE PRODUCT SEARCH ───────────────────────────────────────────
  static Future<List<Product>> searchStore(String store, String query, {int page = 1}) async {
    final cleanStore = store.toLowerCase().replaceAll(' ', '');
    final uri = Uri.parse('$baseUrl/search/$cleanStore?q=${Uri.encodeComponent(query)}&page=$page');

    try {
      final res = await http.get(uri).timeout(timeoutDuration);
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        List<dynamic> items = [];
        if (decoded is List) {
          items = decoded;
        } else if (decoded is Map<String, dynamic> && decoded['data'] is List) {
          items = decoded['data'];
        }
        return items.map((i) => Product.fromJson(i as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      // Return empty list on failure
    }
    return [];
  }

  static Future<Map<String, List<Product>>> searchAllStores(String query) async {
    final results = await Future.wait([
      searchStore('amazon', query),
      searchStore('flipkart', query),
      searchStore('google', query),
    ]);

    return {
      'Amazon': results[0],
      'Flipkart': results[1],
      'Other Stores': results[2],
    };
  }

  // ─── AI ASSISTANT & CHATBOT ───────────────────────────────────────────────
  static Future<String> askChatbot(String message, {String? username, List<Product>? currentProducts}) async {
    final uri = Uri.parse('$baseUrl/chatbot');
    try {
      Map<String, dynamic>? searchContext;
      if (currentProducts != null && currentProducts.isNotEmpty) {
        searchContext = {
          'query': 'Current Search',
          'products': currentProducts.take(8).map((p) => {
            'title': p.title,
            'price': p.price,
            'rating': p.rating,
            'store': p.store,
          }).toList(),
        };
      }

      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': message,
          'username': username,
          'searchContext': searchContext,
        }),
      ).timeout(timeoutDuration);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['reply']?.toString() ?? 'Here are the best deals matching your request!';
      }
    } catch (_) {}
    return 'I can help you compare prices, find the biggest discounts, and detect genuine deals across Amazon, Flipkart, and other stores!';
  }

  // ─── AUTHENTICATION ───────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> checkUser(String username) async {
    final uri = Uri.parse('$baseUrl/check-user');
    try {
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
      ).timeout(timeoutDuration);
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (_) {}
    return {'exists': false};
  }

  static Future<bool> sendOtp(String username) async {
    final uri = Uri.parse('$baseUrl/send-otp');
    try {
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
      ).timeout(timeoutDuration);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> verifyOtp(String username, String otp) async {
    final uri = Uri.parse('$baseUrl/verify-otp');
    try {
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'otp': otp}),
      ).timeout(timeoutDuration);
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (_) {}
    return {'success': false, 'message': 'Verification failed'};
  }

  static Future<bool> setPassword(String username, String password) async {
    final uri = Uri.parse('$baseUrl/set-password');
    try {
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      ).timeout(timeoutDuration);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> login(String username, String password) async {
    final uri = Uri.parse('$baseUrl/login-password');
    try {
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      ).timeout(timeoutDuration);
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (_) {}
    return {'success': false, 'message': 'Login failed'};
  }

  // ─── WATCHLIST ────────────────────────────────────────────────────────────
  static Future<List<WatchlistItem>> getWatchlist(String username) async {
    final uri = Uri.parse('$baseUrl/watchlist/${Uri.encodeComponent(username)}');
    try {
      final res = await http.get(uri).timeout(timeoutDuration);
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List<dynamic>;
        return list.map((i) => WatchlistItem.fromJson(i as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<bool> addToWatchlist(String username, Product product, {String folder = 'My Wishlist'}) async {
    final uri = Uri.parse('$baseUrl/watchlist/add');
    try {
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'product': product.toJson(),
          'folder': folder,
        }),
      ).timeout(timeoutDuration);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> deleteWatchlistItem(String id, String username, String title) async {
    final uri = Uri.parse('$baseUrl/watchlist/${Uri.encodeComponent(id)}?username=${Uri.encodeComponent(username)}&title=${Uri.encodeComponent(title)}');
    try {
      final res = await http.delete(uri).timeout(timeoutDuration);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ─── PRICE ALERTS ─────────────────────────────────────────────────────────
  static Future<List<AlertItem>> getAlerts(String username) async {
    final uri = Uri.parse('$baseUrl/price-alerts/${Uri.encodeComponent(username)}');
    try {
      final res = await http.get(uri).timeout(timeoutDuration);
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List<dynamic>;
        return list.map((i) => AlertItem.fromJson(i as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<bool> addAlert(String username, Product product, double targetPrice) async {
    final uri = Uri.parse('$baseUrl/price-alert');
    try {
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'product': product.toJson(),
          'targetPrice': targetPrice,
        }),
      ).timeout(timeoutDuration);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> updateTargetPrice(String id, double targetPrice) async {
    final uri = Uri.parse('$baseUrl/price-alerts/${Uri.encodeComponent(id)}');
    try {
      final res = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'targetPrice': targetPrice}),
      ).timeout(timeoutDuration);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> deleteAlert(String id, String username, String title) async {
    final uri = Uri.parse('$baseUrl/price-alerts/${Uri.encodeComponent(id)}?username=${Uri.encodeComponent(username)}&title=${Uri.encodeComponent(title)}');
    try {
      final res = await http.delete(uri).timeout(timeoutDuration);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ─── CART & ORDERS ────────────────────────────────────────────────────────
  static Future<List<Product>> getCart(String username) async {
    final uri = Uri.parse('$baseUrl/cart/${Uri.encodeComponent(username)}');
    try {
      final res = await http.get(uri).timeout(timeoutDuration);
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List<dynamic>;
        return list.map((i) => Product.fromJson(i as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<bool> addToCart(String username, Product product) async {
    final uri = Uri.parse('$baseUrl/add-to-cart');
    try {
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'product': product.toJson()}),
      ).timeout(timeoutDuration);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> removeFromCart(String username, {int index = 0, String? title}) async {
    final uri = Uri.parse('$baseUrl/cart/${Uri.encodeComponent(username)}/$index');
    try {
      final res = await http.delete(uri).timeout(timeoutDuration);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> checkout(String username, {String paymentMethod = 'COD'}) async {
    final uri = Uri.parse('$baseUrl/place-order');
    try {
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'paymentMethod': paymentMethod}),
      ).timeout(timeoutDuration);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<List<OrderItem>> getOrders(String username) async {
    final uri = Uri.parse('$baseUrl/orders/${Uri.encodeComponent(username)}');
    try {
      final res = await http.get(uri).timeout(timeoutDuration);
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List<dynamic>;
        return list.map((i) => OrderItem.fromJson(i as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  // ─── SEARCH HISTORY & SEARCH RECORD ──────────────────────────────────────
  static Future<void> recordSearch(String? username, String query) async {
    if (username == null || username.isEmpty) return;
    final uri = Uri.parse('$baseUrl/save-search');
    try {
      await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'query': query}),
      ).timeout(const Duration(seconds: 5));
    } catch (_) {}
  }

  static Future<Map<String, dynamic>> getUserHistory(String username) async {
    final uri = Uri.parse('$baseUrl/history/${Uri.encodeComponent(username)}');
    try {
      final res = await http.get(uri).timeout(timeoutDuration);
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (_) {}
    return {'history': [], 'totalSearches': 0};
  }
}
