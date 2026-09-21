import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/shop_provider.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final cartCount = ref.watch(cartProvider).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () => context.push('/shop/cart'),
              ),
              if (cartCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryRed,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$cartCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: productsAsync.when(
        data: (products) => GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.62,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: products.length,
          itemBuilder: (context, i) {
            final product = products[i];
            return _buildProductCard(context, ref, product);
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, WidgetRef ref, product) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: product.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (context, url) => Container(
                color: AppColors.lightGray,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.lightGray,
                child: const Icon(Icons.image, size: 40),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'ETB ${product.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: AppColors.primaryRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ref.read(cartProvider.notifier).add(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.name} added to cart'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_shopping_cart, size: 14),
                    label: const Text('Add', style: TextStyle(fontSize: 11)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      minimumSize: const Size(0, 32),
                    ),
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