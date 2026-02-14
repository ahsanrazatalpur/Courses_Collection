// lib/services/api_service.dart - COMPLETE UPDATED VERSION

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/product.dart';
import '../models/order.dart';
import '../models/user.dart';
import '../models/cart_item.dart';
import '../models/coupon.dart';
import '../models/review.dart';

class ApiService {
  // ==================== BASE URL ====================
  static String get baseUrl {
    if (kIsWeb) return "http://127.0.0.1:8000/api"; // Flutter Web
    return "http://192.168.1.106:8000/api"; // Mobile/Desktop
  }

  static const int _timeout = 15;

  // ==================== HEADERS ====================
  static Map<String, String> _headers({String? token}) {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ==================== PRODUCTS ====================
  static Future<List<Product>> fetchProducts({String? token}) async {
    try {
      final res = await http
          .get(Uri.parse("$baseUrl/products/"), headers: _headers(token: token))
          .timeout(const Duration(seconds: _timeout));

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        return data.map((e) => Product.fromJson(e)).toList();
      }
      debugPrint("fetchProducts failed: ${res.statusCode} | ${res.body}");
    } catch (e) {
      debugPrint("fetchProducts error: $e");
    }
    return [];
  }

  static Future<bool> addProduct(Product product, {String? token}) async {
    try {
      final url = Uri.parse("$baseUrl/products/");

      if (product.imageFile != null && product.imageFile is File) {
        var request = http.MultipartRequest('POST', url);
        if (token != null && token.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $token';
        }
        request.fields['name'] = product.name;
        request.fields['description'] = product.description;
        request.fields['price'] = product.price.toString();
        request.fields['stock'] = product.stock.toString();
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          (product.imageFile as File).path,
        ));
        final streamedResponse = await request.send();
        final res = await http.Response.fromStream(streamedResponse);
        debugPrint("addProduct multipart response: ${res.statusCode} | ${res.body}");
        return res.statusCode == 201 || res.statusCode == 200;
      } else {
        final res = await http.post(
          url,
          headers: _headers(token: token),
          body: jsonEncode(product.toJson()),
        );
        debugPrint("addProduct JSON response: ${res.statusCode} | ${res.body}");
        return res.statusCode == 201 || res.statusCode == 200;
      }
    } catch (e) {
      debugPrint("addProduct error: $e");
      return false;
    }
  }

  static Future<bool> updateProduct(Product product, {String? token}) async {
    if (product.id == null) return false;
    try {
      final url = Uri.parse("$baseUrl/products/${product.id}/");

      if (product.imageFile != null && product.imageFile is File) {
        var request = http.MultipartRequest('PATCH', url);
        if (token != null && token.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $token';
        }
        request.fields['name'] = product.name;
        request.fields['description'] = product.description;
        request.fields['price'] = product.price.toString();
        request.fields['stock'] = product.stock.toString();
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          (product.imageFile as File).path,
        ));
        final streamedResponse = await request.send();
        final res = await http.Response.fromStream(streamedResponse);
        debugPrint("updateProduct multipart response: ${res.statusCode} | ${res.body}");
        return res.statusCode == 200;
      } else {
        final res = await http.patch(
          url,
          headers: _headers(token: token),
          body: jsonEncode(product.toJson()),
        );
        debugPrint("updateProduct JSON response: ${res.statusCode} | ${res.body}");
        return res.statusCode == 200;
      }
    } catch (e) {
      debugPrint("updateProduct error: $e");
      return false;
    }
  }

  static Future<bool> deleteProduct(int id, {String? token}) async {
    try {
      final res = await http.delete(
        Uri.parse("$baseUrl/products/$id/"),
        headers: _headers(token: token),
      );
      debugPrint("deleteProduct response: ${res.statusCode}");
      return res.statusCode == 204 || res.statusCode == 200;
    } catch (e) {
      debugPrint("deleteProduct error: $e");
      return false;
    }
  }

  // ==================== ORDERS ====================
  
  static Future<List<Order>> fetchAllOrders({required String token}) async {
    try {
      debugPrint("🔍 Fetching all orders from: $baseUrl/admin/orders/");

      final res = await http.get(
        Uri.parse("$baseUrl/admin/orders/"),
        headers: _headers(token: token),
      ).timeout(const Duration(seconds: _timeout));

      debugPrint("📡 Response status: ${res.statusCode}");

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        List data = [];
        
        if (body is List) {
          data = body;
        } else if (body is Map && body.containsKey('orders')) {
          data = body['orders'];
        } else if (body is Map && body.containsKey('results')) {
          data = body['results'];
        }
        
        return data.map((e) => Order.fromJson(e)).toList();
      }
      throw Exception("Failed to load orders: ${res.statusCode}");
    } catch (e) {
      debugPrint("❌ fetchAllOrders error: $e");
      rethrow;
    }
  }

  static Future<List<Order>> fetchOrders({required String token}) async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/orders/"),
        headers: _headers(token: token),
      ).timeout(const Duration(seconds: _timeout));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        List data = body is List ? body : (body['orders'] ?? body['results'] ?? []);
        return data.map((e) => Order.fromJson(e)).toList();
      }
      throw Exception("Failed to load orders");
    } catch (e) {
      debugPrint("❌ fetchOrders error: $e");
      rethrow;
    }
  }

  static Future<Order?> fetchOrder(int orderId, {required String token}) async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/orders/$orderId/"),
        headers: _headers(token: token),
      ).timeout(const Duration(seconds: _timeout));

      if (res.statusCode == 200) {
        return Order.fromJson(jsonDecode(res.body));
      }
    } catch (e) {
      debugPrint("fetchOrder error: $e");
    }
    return null;
  }

  static Future<int> fetchNewOrdersCount({required String token}) async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/admin/orders/new/count/"),
        headers: _headers(token: token),
      ).timeout(const Duration(seconds: _timeout));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return (data['count'] as int?) ?? 0;
      }
    } catch (e) {
      debugPrint("❌ fetchNewOrdersCount error: $e");
    }
    return 0;
  }

  static Future<Map<String, dynamic>?> placeOrderFromCart({
    required String token,
    required Map<String, dynamic> orderData,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/orders/"),
        headers: _headers(token: token),
        body: jsonEncode(orderData),
      ).timeout(const Duration(seconds: _timeout));

      if (res.statusCode == 201 || res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      debugPrint("❌ placeOrderFromCart error: $e");
    }
    return null;
  }

  static Future<Map<String, dynamic>?> placeBuyNowOrder({
    required String token,
    required Map<String, dynamic> orderData,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/orders/buy_now/"),
        headers: _headers(token: token),
        body: jsonEncode(orderData),
      ).timeout(const Duration(seconds: _timeout));

      if (res.statusCode == 201 || res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      debugPrint("❌ placeBuyNowOrder error: $e");
    }
    return null;
  }

  static Future<bool> updateOrderStatusByAdmin({
    required int orderId,
    required String status,
    required String token,
  }) async {
    try {
      final res = await http.patch(
        Uri.parse("$baseUrl/admin/orders/$orderId/"),
        headers: _headers(token: token),
        body: jsonEncode({'status': status}),
      ).timeout(const Duration(seconds: _timeout));

      return res.statusCode == 200;
    } catch (e) {
      debugPrint("❌ updateOrderStatusByAdmin error: $e");
      return false;
    }
  }

  static Future<bool> updateOrderStatus(int orderId, String status,
      {required String token}) async {
    return updateOrderStatusByAdmin(
      orderId: orderId,
      status: status,
      token: token,
    );
  }

  // ==================== USERS ====================
  
  static Future<List<User>> fetchUsers({required String token}) async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/users/admin/users/"),
        headers: _headers(token: token),
      ).timeout(const Duration(seconds: _timeout));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final List data = body is List ? body : (body['users'] as List);
        return data.map((e) => User.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("fetchUsers error: $e");
    }
    return [];
  }

  static Future<bool> updateUser({
    required int userId,
    required Map<String, dynamic> data,
    required String token,
  }) async {
    try {
      final res = await http.patch(
        Uri.parse("$baseUrl/users/admin/users/$userId/"),
        headers: _headers(token: token),
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: _timeout));
      
      return res.statusCode == 200;
    } catch (e) {
      debugPrint("updateUser error: $e");
      return false;
    }
  }

  static Future<bool> deleteUser(int userId, {required String token}) async {
    try {
      final res = await http.delete(
        Uri.parse("$baseUrl/users/admin/users/$userId/"),
        headers: _headers(token: token),
      ).timeout(const Duration(seconds: _timeout));
      
      return res.statusCode == 204 || res.statusCode == 200;
    } catch (e) {
      debugPrint("deleteUser error: $e");
      return false;
    }
  }

  static Future<User?> fetchUserInfo({required String token}) async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/users/me/"),
        headers: _headers(token: token),
      ).timeout(const Duration(seconds: _timeout));
      
      if (res.statusCode == 200) {
        return User.fromJson(jsonDecode(res.body));
      }
    } catch (e) {
      debugPrint("fetchUserInfo error: $e");
    }
    return null;
  }

  // ==================== CART ====================
  
  static Future<List<CartItem>> fetchCart({required String token}) async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/cart/"),
        headers: _headers(token: token),
      ).timeout(const Duration(seconds: _timeout));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body)['items'] as List;
        return data.map((e) => CartItem.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("fetchCart error: $e");
    }
    return [];
  }

  static Future<bool> addToCart({
    required int productId,
    required int quantity,
    required String token,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/cart/add_item/"),
        headers: _headers(token: token),
        body: jsonEncode({'product_id': productId, 'quantity': quantity}),
      ).timeout(const Duration(seconds: _timeout));

      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      debugPrint("addToCart error: $e");
      return false;
    }
  }

  static Future<bool> updateCartItemQuantity({
    required int productId,
    required int quantity,
    required String token,
  }) async {
    try {
      final res = await http.patch(
        Uri.parse("$baseUrl/cart/update_item/"),
        headers: _headers(token: token),
        body: jsonEncode({'product_id': productId, 'quantity': quantity}),
      ).timeout(const Duration(seconds: _timeout));

      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      debugPrint("updateCartItemQuantity error: $e");
      return false;
    }
  }

  static Future<bool> removeFromCart({
    required int productId,
    required String token,
  }) async {
    try {
      final res = await http.delete(
        Uri.parse("$baseUrl/cart/remove_item/"),
        headers: _headers(token: token),
        body: jsonEncode({'product_id': productId}),
      ).timeout(const Duration(seconds: _timeout));

      return res.statusCode == 200 || res.statusCode == 204;
    } catch (e) {
      debugPrint("removeFromCart error: $e");
      return false;
    }
  }

  // ==================== COUPONS ====================
  
  static Future<List<Coupon>> fetchCoupons({required String token}) async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/coupons/"),
        headers: _headers(token: token),
      ).timeout(const Duration(seconds: _timeout));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        List data = body is List ? body : (body['coupons'] ?? body['results'] ?? []);
        return data.map((e) => Coupon.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("❌ fetchCoupons error: $e");
    }
    return [];
  }

  static Future<bool> createCoupon(Coupon coupon, {required String token}) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/coupons/"),
        headers: _headers(token: token),
        body: jsonEncode(coupon.toJson()),
      ).timeout(const Duration(seconds: _timeout));

      return res.statusCode == 201 || res.statusCode == 200;
    } catch (e) {
      debugPrint("❌ createCoupon error: $e");
      return false;
    }
  }

  static Future<bool> updateCoupon(Coupon coupon, {required String token}) async {
    if (coupon.id == null) return false;
    
    try {
      final res = await http.put(
        Uri.parse("$baseUrl/coupons/${coupon.id}/"),
        headers: _headers(token: token),
        body: jsonEncode(coupon.toJson()),
      ).timeout(const Duration(seconds: _timeout));

      return res.statusCode == 200;
    } catch (e) {
      debugPrint("❌ updateCoupon error: $e");
      return false;
    }
  }

  static Future<bool> deleteCoupon(int id, {required String token}) async {
    try {
      final res = await http.delete(
        Uri.parse("$baseUrl/coupons/$id/"),
        headers: _headers(token: token),
      ).timeout(const Duration(seconds: _timeout));

      return res.statusCode == 204 || res.statusCode == 200;
    } catch (e) {
      debugPrint("❌ deleteCoupon error: $e");
      return false;
    }
  }
  
  static Future<double?> applyCoupon({
    required String code,
    required double cartTotal,
    required String token,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/coupons/validate/"),
        headers: _headers(token: token),
        body: jsonEncode({'code': code, 'cart_total': cartTotal}),
      ).timeout(const Duration(seconds: _timeout));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return (data['discount'] as num).toDouble();
      }
    } catch (e) {
      debugPrint("applyCoupon error: $e");
    }
    return null;
  }

  // ==================== REVIEWS ====================
  
  /// Fetch reviews for a specific product
  static Future<Map<String, dynamic>?> fetchProductReviews({
    required int productId,
    int page = 1,
    int pageSize = 10,
    String? token,
  }) async {
    try {
      debugPrint("🔍 Fetching reviews for product #$productId");
      
      final res = await http.get(
        Uri.parse("$baseUrl/reviews/product/$productId/?page=$page&page_size=$pageSize"),
        headers: _headers(token: token),
      ).timeout(const Duration(seconds: _timeout));

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      debugPrint("❌ fetchProductReviews error: $e");
    }
    return null;
  }

  /// Fetch user's own reviews
  static Future<List<Review>> fetchMyReviews({required String token}) async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/reviews/my-reviews/"),
        headers: _headers(token: token),
      ).timeout(const Duration(seconds: _timeout));

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        return data.map((e) => Review.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("❌ fetchMyReviews error: $e");
    }
    return [];
  }

  /// Fetch products pending review
  static Future<List<PendingReviewProduct>> fetchPendingReviews({required String token}) async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/reviews/pending/"),
        headers: _headers(token: token),
      ).timeout(const Duration(seconds: _timeout));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List products = data['products'] ?? [];
        return products.map((e) => PendingReviewProduct.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("❌ fetchPendingReviews error: $e");
    }
    return [];
  }

  /// Submit a new review
  static Future<bool> submitReview({
    required int productId,
    required int rating,
    required String comment,
    String? title,
    required String token,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/reviews/"),
        headers: _headers(token: token),
        body: jsonEncode({
          'product': productId,
          'rating': rating,
          'comment': comment,
          if (title != null && title.isNotEmpty) 'title': title,
        }),
      ).timeout(const Duration(seconds: _timeout));

      return res.statusCode == 201 || res.statusCode == 200;
    } catch (e) {
      debugPrint("❌ submitReview error: $e");
      return false;
    }
  }

  /// Update an existing review
  static Future<bool> updateReview({
    required int reviewId,
    required int rating,
    required String comment,
    String? title,
    required String token,
  }) async {
    try {
      final res = await http.patch(
        Uri.parse("$baseUrl/reviews/$reviewId/"),
        headers: _headers(token: token),
        body: jsonEncode({
          'rating': rating,
          'comment': comment,
          if (title != null && title.isNotEmpty) 'title': title,
        }),
      ).timeout(const Duration(seconds: _timeout));

      return res.statusCode == 200;
    } catch (e) {
      debugPrint("❌ updateReview error: $e");
      return false;
    }
  }

  /// Delete a review
  static Future<bool> deleteReview({
    required int reviewId,
    required String token,
  }) async {
    try {
      final res = await http.delete(
        Uri.parse("$baseUrl/reviews/$reviewId/"),
        headers: _headers(token: token),
      ).timeout(const Duration(seconds: _timeout));

      return res.statusCode == 204 || res.statusCode == 200;
    } catch (e) {
      debugPrint("❌ deleteReview error: $e");
      return false;
    }
  }

  /// Like/unlike a review
  static Future<Map<String, dynamic>?> toggleReviewLike({
    required int reviewId,
    required String token,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/reviews/$reviewId/like/"),
        headers: _headers(token: token),
      ).timeout(const Duration(seconds: _timeout));

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      debugPrint("❌ toggleReviewLike error: $e");
    }
    return null;
  }

  /// Get users who liked a review
  static Future<Map<String, dynamic>?> getReviewLikes({
    required int reviewId,
    String? token,
  }) async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/reviews/$reviewId/likes/"),
        headers: _headers(token: token),
      ).timeout(const Duration(seconds: _timeout));

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      debugPrint("❌ getReviewLikes error: $e");
    }
    return null;
  }

  /// Check if user can review a product
  static Future<ReviewEligibility?> checkReviewEligibility({
    required int productId,
    required String token,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/reviews/check-eligibility/"),
        headers: _headers(token: token),
        body: jsonEncode({'product_id': productId}),
      ).timeout(const Duration(seconds: _timeout));

      if (res.statusCode == 200) {
        return ReviewEligibility.fromJson(jsonDecode(res.body));
      }
    } catch (e) {
      debugPrint("❌ checkReviewEligibility error: $e");
    }
    return null;
  }

  // ==================== ADMIN: REVIEWS ====================
  
  /// Admin: Fetch all reviews
  static Future<List<Review>> fetchAllReviews({
    required String token,
    int? minRating,
    int? maxRating,
    int? productId,
  }) async {
    try {
      String queryParams = '';
      final params = <String>[];
      
      if (minRating != null) params.add('min_rating=$minRating');
      if (maxRating != null) params.add('max_rating=$maxRating');
      if (productId != null) params.add('product=$productId');
      
      if (params.isNotEmpty) queryParams = '?${params.join('&')}';
      
      // ✅ FIXED: Using new endpoint
      final res = await http.get(
        Uri.parse("$baseUrl/reviews/admin/all/$queryParams"),
        headers: _headers(token: token),
      ).timeout(const Duration(seconds: _timeout));

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        return data.map((e) => Review.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("❌ fetchAllReviews error: $e");
    }
    return [];
  }

  /// Admin: Delete any review
  static Future<bool> adminDeleteReview({
    required int reviewId,
    required String token,
  }) async {
    try {
      // ✅ FIXED: Using new endpoint
      final res = await http.delete(
        Uri.parse("$baseUrl/reviews/admin/$reviewId/"),
        headers: _headers(token: token),
      ).timeout(const Duration(seconds: _timeout));

      return res.statusCode == 204 || res.statusCode == 200;
    } catch (e) {
      debugPrint("❌ adminDeleteReview error: $e");
      return false;
    }
  }

  /// Admin: Get flagged reviews
  static Future<List<Review>> fetchFlaggedReviews({required String token}) async {
    try {
      // ✅ FIXED: Using new endpoint
      final res = await http.get(
        Uri.parse("$baseUrl/reviews/admin/flagged/"),
        headers: _headers(token: token),
      ).timeout(const Duration(seconds: _timeout));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List reviews = data['reviews'] ?? [];
        return reviews.map((e) => Review.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("❌ fetchFlaggedReviews error: $e");
    }
    return [];
  }
}