import 'package:flutter/material.dart';

import '../../core/theme/rimi_colors.dart';
import '../../core/theme/rimi_typography.dart';

/// Product card matched to Google Stitch design.
/// - Rounded card with product photo
/// - Cashback badge overlay (color customizable per section)
/// - Product name, price (coral), rating with sold count
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.cashbackColor = RimiColors.primary,
  });

  final dynamic product;
  final VoidCallback? onTap;
  final Color cashbackColor;

  @override
  Widget build(BuildContext context) {
    final name = product.name?.toString() ?? 'Produk';
    final price = product.price is int
        ? product.price
        : (product.price as num?)?.toInt() ?? 0;
    final images = product.images as List<dynamic>?;
    final image = (images != null && images.isNotEmpty)
        ? images.first.toString()
        : null;
    final stock = product.stock ?? 0;
    final cashback = _computeCashback(product);
    final rating = 4.8; // TODO: from BE when field ready
    final sold = _fakeSold(name);

    final priceStr = 'Rp ${price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        )}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---- Image + cashback badge ----
            AspectRatio(
              aspectRatio: 1.0,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (image != null && image.isNotEmpty)
                    Image.network(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const _PlaceholderImage(),
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const _PlaceholderImage();
                      },
                    )
                  else
                    const _PlaceholderImage(),
                  // Cashback badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: cashbackColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$cashback% Cashback',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  if (stock <= 0)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.45),
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: RimiColors.error,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Stok Habis',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // ---- Info ----
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: RimiTypography.bodySmall.copyWith(
                      color: RimiColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    priceStr,
                    style: RimiTypography.titleSmall.copyWith(
                      color: RimiColors.secondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 12, color: RimiColors.tertiary),
                      const SizedBox(width: 2),
                      Text(
                        '$rating',
                        style: RimiTypography.labelSmall.copyWith(fontSize: 10),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '|',
                        style: RimiTypography.labelSmall.copyWith(fontSize: 10, color: RimiColors.border),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '$sold terjual',
                          style: RimiTypography.labelSmall.copyWith(fontSize: 10),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _computeCashback(dynamic product) {
    final pct = product.cashbackPercentage;
    if (pct == null) return 5;
    if (pct is num) return pct.toInt();
    return 5;
  }

  String _fakeSold(String seed) {
    // Deterministic pseudo-random from name length so it doesn't flicker
    final n = seed.length * 37 % 5000;
    if (n > 2000) return '${(n / 1000).toStringAsFixed(1)}rb+';
    return '$n+';
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
