import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/shop_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: cart.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 64, color: AppColors.mediumGray),
                  SizedBox(height: 16),
                  Text('Your cart is empty',
                      style: TextStyle(fontSize: 16, color: AppColors.darkGray)),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: cart.length,
                    itemBuilder: (context, i) {
                      final item = cart[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        child: ListTile(
                          title: Text(item.product.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13)),
                          subtitle: Text(
                            'ETB ${item.product.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                                color: AppColors.primaryRed,
                                fontWeight: FontWeight.bold),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () => ref
                                    .read(cartProvider.notifier)
                                    .decrement(item.product.id),
                              ),
                              Text('${item.quantity}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () => ref
                                    .read(cartProvider.notifier)
                                    .increment(item.product.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Total + Checkout
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(
                        top: BorderSide(color: AppColors.borderGray)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total:',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(
                            'ETB ${ref.read(cartProvider.notifier).total.toStringAsFixed(0)}',
                            style: const TextStyle(
                                color: AppColors.primaryRed,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => context.push('/shop/checkout'),
                          child: const Text('Proceed to Checkout'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}