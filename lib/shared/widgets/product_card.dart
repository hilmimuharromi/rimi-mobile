import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/rimi_colors.dart';
import '../../core/theme/rimi_typography.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, this.onTap});
  final dynamic product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final name = product.name?.toString() ?? 'Produk';
    final price = product.price is int ? product.price : (product.price as num?)?.toInt() ?? 0;
    final images = product.images as List<dynamic>?;
    final image = (images != null && images.isNotEmpty) ? images.first.toString() : null;
    final stock = product.stock ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: RimiColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: RimiColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (image != null && image.isNotEmpty)
                    Image.network(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const _PlaceholderImage(),
                    )
                  else
                    const _PlaceholderImage(),
                  if (stock <= 0)
                    Positioned.fill(
                      child: Container(
                        color: RimiColors.black.withValues(alpha: 0.45),
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: RimiColors.error,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Stok Habis',
                            style: TextStyle(color: RimiColors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: RimiTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Rp ${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                      style: RimiTypography.titleSmall.copyWith(color: RimiColors.primaryDeep),
                    ),
                    if (stock > 0)
                      Text(
                        'Stok: $stock',
                        style: RimiTypography.caption.copyWith(color: RimiColors.neutralMuted),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  const _PlaceholderImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: RimiColors.surface,
      child: const Center(
        child: Icon(Icons.image_outlined, size: 40, color: RimiColors.neutralMuted),
      ),
    );
  }
}
