import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_config.dart';
import 'api_exception.dart';
import 'dio_client.dart';
import '../../shared/models/product.dart';
import '../../shared/models/user.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    dio: ref.watch(dioProvider),
    prefs: ref.watch(sharedPreferencesProvider),
  );
});

class ApiClient {
  ApiClient({required this.dio, required this.prefs});

  final Dio dio;
  final SharedPreferences prefs;

  // ---------- Auth ----------

  Future<AuthSession> login({
    required String phoneOrEmail,
    required String password,
  }) async {
    final res = await dio.post(
      '/auth/login',
      data: {
        'phone_or_email': phoneOrEmail,
        'password': password,
      },
    );
    final session = unwrapData(res.data, (raw) {
      return AuthSession.fromJson(raw as Map<String, dynamic>);
    });
    await _persistSession(session);
    return session;
  }

  Future<AuthSession> register({
    String? phone,
    String? email,
    required String password,
    String? fullName,
    String? referralCode,
  }) async {
    final res = await dio.post(
      '/auth/register',
      data: {
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        'password': password,
        if (fullName != null) 'full_name': fullName,
        if (referralCode != null) 'referral_code': referralCode,
      },
    );
    final session = unwrapData(res.data, (raw) {
      return AuthSession.fromJson(raw as Map<String, dynamic>);
    });
    await _persistSession(session);
    return session;
  }

  Future<User> me() async {
    final res = await dio.get('/auth/me');
    return unwrapData(res.data, (raw) {
      // some backends wrap { user: ... }
      if (raw is Map && raw['user'] is Map) {
        return User.fromJson(raw['user'] as Map<String, dynamic>);
      }
      return User.fromJson(raw as Map<String, dynamic>);
    });
  }

  Future<void> logout() async {
    try {
      await dio.post('/auth/logout');
    } catch (_) {
      // ignore network errors on logout
    }
    await clearSession();
  }

  Future<void> _persistSession(AuthSession session) async {
    await prefs.setString(AppConfig.accessTokenKey, session.tokens.accessToken);
    await prefs.setString(AppConfig.refreshTokenKey, session.tokens.refreshToken);
    await prefs.setString(AppConfig.userJsonKey, jsonEncode(session.user.toJson()));
  }

  Future<void> clearSession() async {
    await prefs.remove(AppConfig.accessTokenKey);
    await prefs.remove(AppConfig.refreshTokenKey);
    await prefs.remove(AppConfig.userJsonKey);
  }

  bool get isLoggedIn {
    final t = prefs.getString(AppConfig.accessTokenKey);
    return t != null && t.isNotEmpty;
  }

  User? get cachedUser {
    final raw = prefs.getString(AppConfig.userJsonKey);
    if (raw == null) return null;
    try {
      return User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  // ---------- Catalog ----------

  Future<PagedResult<Product>> listProducts({
    int page = 1,
    int limit = 20,
    String? category,
    String? search,
  }) async {
    final res = await dio.get(
      '/products',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (category != null && category.isNotEmpty) 'category': category,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    return unwrapData(res.data, (raw) {
      final map = raw as Map<String, dynamic>? ?? {};
      final items = (map['items'] as List? ?? [])
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
      final meta = PageMeta.fromJson(map['meta'] as Map<String, dynamic>?);
      return PagedResult(items: items, meta: meta);
    });
  }

  Future<Product> getProduct(String id) async {
    final res = await dio.get('/products/$id');
    return unwrapData(res.data, (raw) {
      if (raw is Map && raw['product'] is Map) {
        return Product.fromJson(raw['product'] as Map<String, dynamic>);
      }
      return Product.fromJson(raw as Map<String, dynamic>);
    });
  }

  Future<List<Category>> listCategories() async {
    final res = await dio.get('/categories');
    return unwrapData(res.data, (raw) {
      if (raw is List) {
        return raw.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
      }
      if (raw is Map) {
        final items = raw['items'] as List? ?? raw['categories'] as List? ?? [];
        return items.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
      }
      return <Category>[];
    });
  }

  // ---------- Cart ----------

  Future<Map<String, dynamic>> getCart() async {
    final res = await dio.get('/cart/');
    return unwrapData(res.data, (raw) => raw as Map<String, dynamic>? ?? {});
  }

  Future<void> addToCart({required String productId, int qty = 1}) async {
    await dio.post('/cart/items', data: {'product_id': productId, 'qty': qty});
  }

  Future<void> updateCartItem({required String itemId, required int qty}) async {
    await dio.patch('/cart/items/$itemId', data: {'qty': qty});
  }

  Future<void> removeFromCart(String itemId) async {
    await dio.delete('/cart/items/$itemId');
  }

  // ---------- Orders ----------

  Future<List<Map<String, dynamic>>> listOrders({int page = 1, int limit = 20}) async {
    final res = await dio.get('/orders/', queryParameters: {'page': page, 'limit': limit});
    return unwrapData(res.data, (raw) {
      if (raw is Map) {
        final items = raw['items'] as List? ?? [];
        return items.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      if (raw is List) {
        return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return <Map<String, dynamic>>[];
    });
  }

  Future<Map<String, dynamic>> getOrder(String id) async {
    final res = await dio.get('/orders/$id');
    return unwrapData(res.data, (raw) => raw as Map<String, dynamic>? ?? {});
  }

  Future<Map<String, dynamic>> createOrder({
    required String addressId,
    String? shippingOption,
    String? notes,
  }) async {
    final res = await dio.post('/orders/', data: {
      'address_id': addressId,
      if (shippingOption != null) 'shipping_option': shippingOption,
      if (notes != null) 'notes': notes,
    });
    return unwrapData(res.data, (raw) => raw as Map<String, dynamic>? ?? {});
  }

  // ---------- Redemption ----------

  Future<List<dynamic>> getRedemptionCatalog() async {
    final res = await dio.get('/redemption/catalog');
    return unwrapData(res.data, (raw) {
      if (raw is List) return raw;
      if (raw is Map) return raw['items'] as List? ?? raw['catalog'] as List? ?? [];
      return <dynamic>[];
    });
  }

  // ---------- Wallet ----------

  Future<Map<String, dynamic>> getWallet() async {
    final res = await dio.get('/wallet/');
    return unwrapData(res.data, (raw) => raw as Map<String, dynamic>? ?? {});
  }

  // ---------- Referral ----------

  Future<Map<String, dynamic>> getReferralCode() async {
    final res = await dio.get('/referral/code');
    return unwrapData(res.data, (raw) => raw as Map<String, dynamic>? ?? {});
  }
}

String apiErrorMessage(Object e) {
  if (e is DioException && e.error is ApiException) {
    return (e.error as ApiException).message;
  }
  if (e is ApiException) return e.message;
  return e.toString();
}
