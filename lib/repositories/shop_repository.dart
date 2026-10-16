import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../models/product.dart';
import '../models/payment_result.dart';

class ShopRepository {
  final ApiClient _client = ApiClient();

  /// List products with pagination + search
  Future<List<Product>> list({
    int page = 1,
    int limit = 20,
    String? query,
  }) async {
    try {
      final response = await _client.dio.get(
        'shop',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (query != null && query.isNotEmpty) 'q': query,
        },
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final List<dynamic> items;
        if (data is List) {
          items = data;
        } else if (data is Map && data['items'] is List) {
          items = data['items'];
        } else {
          return [];
        }
        return items.map((j) => Product.fromJson(j)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Shop list error: $e');
      return _getMockProducts();
    }
  }

  /// Get single product detail
  Future<Product?> detail(String id) async {
    try {
      final response = await _client.dio.get('shop/$id');
      if (response.data['success'] == true) {
        return Product.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      debugPrint('Shop detail error: $e');
      return null;
    }
  }

  /// Check ownership
  Future<bool> owned(String id) async {
    try {
      final response = await _client.dio.get('shop/$id/owned');
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  /// Purchase history
  Future<List<Product>> history() async {
    try {
      final response = await _client.dio.get('shop/history');
      if (response.data['success'] == true) {
        final items = response.data['data']['items'] as List<dynamic>? ?? [];
        return items.map((j) => Product.fromJson(j)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Purchase history error: $e');
      return [];
    }
  }

  /// Create checkout — returns URL to open in WebView
  Future<PaymentCheckout?> createCheckout({
    required String shopId,
    required String gateway,
    required String phone,
  }) async {
    try {
      final response = await _client.dio.post(
        'payment/checkout',
        data: {
          'shop_id': shopId,
          'gateway': gateway,
          'phone': phone,
        },
      );

      if (response.data['success'] == true) {
        return PaymentCheckout.fromJson(response.data['data']);
      }
      return null;
    } on DioException catch (e) {
      debugPrint('Checkout error: ${e.response?.data ?? e.message}');
      return null;
    }
  }

  /// Poll payment status
  Future<PaymentStatus?> paymentStatus(String orderId) async {
    try {
      final response = await _client.dio.get('payment/status/$orderId');
      if (response.data['success'] == true) {
        return PaymentStatus.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      debugPrint('Payment status error: $e');
      return null;
    }
  }

  /// Available payment gateways
  Future<List<String>> gateways() async {
    try {
      final response = await _client.dio.get('payment/gateways');
      if (response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          return data.map((g) => g.toString()).toList();
        }
        if (data is Map && data['items'] is List) {
          return (data['items'] as List).map((g) => g.toString()).toList();
        }
      }
      return ['chapa'];
    } catch (e) {
      return ['chapa'];
    }
  }

  List<Product> _getMockProducts() {
    return [
      Product(
        id: '1',
        name: 'Oromia Cultural T-Shirt',
        description: 'Traditional Oromo design cotton t-shirt',
        price: 450,
        imageUrl: 'https://picsum.photos/seed/shop1/400/400',
        category: 'Clothing',
        stock: 25,
      ),
      Product(
        id: '2',
        name: 'Kallacha Oromia Book Set',
        description: 'Complete yearly book collection 2020-2025',
        price: 1200,
        imageUrl: 'https://picsum.photos/seed/shop2/400/400',
        category: 'Books',
        stock: 15,
      ),
      Product(
        id: '3',
        name: 'Oromo Coffee Beans (1kg)',
        description: 'Premium roasted Oromo coffee beans',
        price: 380,
        imageUrl: 'https://picsum.photos/seed/shop3/400/400',
        category: 'Food',
        stock: 50,
      ),
      Product(
        id: '4',
        name: 'Traditional Oromo Basket',
        description: 'Handwoven traditional Oromo basket',
        price: 650,
        imageUrl: 'https://picsum.photos/seed/shop4/400/400',
        category: 'Handicraft',
        stock: 12,
      ),
      Product(
        id: '5',
        name: 'Oromia Map Poster',
        description: 'High-quality printed Oromia region map',
        price: 220,
        imageUrl: 'https://picsum.photos/seed/shop5/400/400',
        category: 'Decor',
        stock: 30,
      ),
      Product(
        id: '6',
        name: 'Oromo Music CD Collection',
        description: 'Traditional Oromo music collection',
        price: 550,
        imageUrl: 'https://picsum.photos/seed/shop6/400/400',
        category: 'Music',
        stock: 20,
      ),
      Product(
        id: '7',
        name: 'Oromia Travel Guide Book',
        description: 'Complete travel guide to Oromia region',
        price: 480,
        imageUrl: 'https://picsum.photos/seed/shop7/400/400',
        category: 'Books',
        stock: 18,
      ),
      Product(
        id: '8',
        name: 'Oromo Traditional Scarf',
        description: 'Colorful traditional Oromo scarf',
        price: 320,
        imageUrl: 'https://picsum.photos/seed/shop8/400/400',
        category: 'Clothing',
        stock: 22,
      ),
    ];
  }
}