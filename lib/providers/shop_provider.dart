import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import '../repositories/shop_repository.dart';

final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  return ShopRepository();
});

final productsProvider = FutureProvider<List<Product>>((ref) async {
  return ref.watch(shopRepositoryProvider).list();
});

// ============ CART ============
final cartProvider =
    StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void add(Product product) {
    final existing = state.indexWhere((i) => i.product.id == product.id);
    if (existing != -1) {
      final updated = [...state];
      updated[existing].quantity++;
      state = updated;
    } else {
      state = [...state, CartItem(product: product)];
    }
  }

  void remove(String productId) {
    state = state.where((i) => i.product.id != productId).toList();
  }

  void increment(String productId) {
    state = state.map((i) {
      if (i.product.id == productId) {
        i.quantity++;
      }
      return i;
    }).toList();
  }

  void decrement(String productId) {
    state = state
        .map((i) {
          if (i.product.id == productId && i.quantity > 1) {
            i.quantity--;
          }
          return i;
        })
        .where((i) => i.quantity > 0)
        .toList();
  }

  void clear() => state = [];

  double get total => state.fold(0.0, (s, i) => s + i.subtotal);
  int get itemCount => state.fold(0, (s, i) => s + i.quantity);
}