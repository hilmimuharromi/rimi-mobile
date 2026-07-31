import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_client.dart';
import '../../../core/theme/rimi_colors.dart';
import '../../../core/theme/rimi_typography.dart';
import '../../../shared/models/product.dart';
import '../../home/presentation/home_page.dart';

class ProductDetailPage extends ConsumerWidget {
  const ProductDetailPage({super.key, required this.productId});
  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));
    final api = ref.watch(apiClientProvider);

    return Scaffold(
      backgroundColor: RimiColors.background,
      appBar: AppBar(
        title: const Text('Detail Produk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () => context.go('/cart'),
          ),
        ],
      ),
      body: productAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(apiErrorMessage(e), textAlign: TextAlign.center),
          ),
        ),
        data: (product) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (product.imageUrl != null)
                Image.network(
                  product.imageUrl!,
                  height: 280,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              else
                Container(
                  height: 280,
                  color: RimiColors.surface,
                  child: const Center(
                    child: Icon(Icons.image_not_supported_rounded, size: 64, color: RimiColors.neutralMuted),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: RimiTypography.headlineMedium),
                    const SizedBox(height: 4),
                    Text(
                      'Rp ${product.price.toStringAsFixed(0)}',
                      style: RimiTypography.headlineLarge.copyWith(color: RimiColors.primaryDeep),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 20, color: Color(0xFFFFC24B)),
                        const SizedBox(width: 4),
                        Text('${product.rating} • ${product.reviews} ulasan', style: RimiTypography.bodyMedium),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Deskripsi', style: RimiTypography.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      product.description,
                      style: RimiTypography.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Text('Stok: ${product.stock}', style: RimiTypography.bodyMedium),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            icon: const Icon(Icons.shopping_cart_outlined),
                            label: const Text('Masukkan Keranjang'),
                            style: FilledButton.styleFrom(
                              backgroundColor: RimiColors.primaryDeep,
                              foregroundColor: RimiColors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () async {
                              await api.addToCart(productId);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('✅ Ditambahkan ke keranjang')),
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => context.go('/cart'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              borderSide: const BorderSide(color: RimiColors.primaryDeep),
                            ),
                            child: const Text('Beli Sekarang'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('Kategori', style: RimiTypography.titleMedium),
                    const SizedBox(height: 8),
                    Chip(
                      label: Text(product.category?.name ?? 'Produk Lainnya'),
                      backgroundColor: RimiColors.primary.withValues(alpha: 0.1),
                      side: const BorderSide(color: RimiColors.primary),
                      labelStyle: RimiTypography.labelMedium.copyWith(color: RimiColors.primaryDeep),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final productDetailProvider = FutureProvider.family<Product, String>((ref, id) async {
  final api = ref.watch(apiClientProvider);
  return api.getProduct(id);
});
