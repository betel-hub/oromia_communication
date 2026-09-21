import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/product.dart';

class ShopRepository {
  Future<List<Product>> getProducts() async {
    final jsonString = await rootBundle.loadString('assets/mock/shop.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((j) => Product.fromJson(j)).toList();
  }

  // Mock checkout — returns a fake URL for later WebView
  Future<Map<String, dynamic>> checkout({
    required List<CartItem> items,
    required String phone,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    final total = items.fold<double>(0, (s, i) => s + i.subtotal);
    return {
      'order_id': 'OCB-M-${DateTime.now().millisecondsSinceEpoch}',
      'amount': total,
      'currency': 'ETB',
      'checkout_url': 'https://checkout.example.com/mock',
      'status': 'pending',
    };
  }
}