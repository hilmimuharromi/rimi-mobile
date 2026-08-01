import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_client.dart';
import '../../../core/theme/rimi_colors.dart';
import '../../../core/theme/rimi_typography.dart';
import '../../../shared/models/product.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  const ProductDetailPage({super.key, required this.productId});
  final String productId;

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  int _qty = 1;
  int _imgIndex = 0;

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));
    final api = ref.watch(apiClientProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: RimiColors.neutral),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text('Rimi', style: RimiTypography.headlineMedium.copyWith(fontWeight: FontWeight.w800)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: RimiColors.neutral),
            onPressed: () => context.push('/cart'),
          ),
          IconButton(
            icon: const Icon(Icons.ios_share_rounded, color: RimiColors.neutral),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Image carousel area ----
              _ImageCarousel(
                images: product.images ?? [],
                activeIndex: _imgIndex,
                onChanged: (i) => setState(() => _imgIndex = i),
              ),
              const SizedBox(height: 16),

              // ---- Title + rating ----
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: RimiTypography.headlineLarge.copyWith(fontSize: 20, height: 1.3, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: RimiColors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, color: RimiColors.tertiary, size: 14),
                          const SizedBox(width: 2),
                          Text('4.9', style: RimiTypography.labelMedium.copyWith(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // ---- Price + discount ----
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _formatRp(product.price),
                      style: RimiTypography.headlineMedium.copyWith(
                        color: RimiColors.primaryDeep,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDEAEA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Diskon 15%',
                        style: RimiTypography.labelSmall.copyWith(
                          color: const Color(0xFFE53935),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ---- Trust badges ----
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _TrustChip(label: 'Teruji Dermatologis'),
                    const SizedBox(width: 8),
                    _TrustChip(label: '100% Organik'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ---- Points banner ----
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBF4FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2979FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.stars_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Untung Pakai Rimi!', style: RimiTypography.labelLarge.copyWith(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            RichText(
                              text: TextSpan(
                                text: 'Dapatkan ',
                                style: RimiTypography.bodySmall.copyWith(fontSize: 12, color: RimiColors.textSecondary),
                                children: [
                                  TextSpan(
                                    text: '5.000 Poin ',
                                    style: RimiTypography.bodySmall.copyWith(fontSize: 12, fontWeight: FontWeight.w700, color: RimiColors.textPrimary),
                                  ),
                                  const TextSpan(text: 'belanja ini'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: RimiColors.neutralMuted),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ---- Kandungan Produk ----
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(child: Text('Kandungan Produk', style: RimiTypography.titleLarge.copyWith(fontWeight: FontWeight.w700))),
                    Text('Lihat Semua', style: RimiTypography.labelMedium.copyWith(color: const Color(0xFF2979FF))),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 96,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: const [
                    _IngredientCard(icon: Icons.local_florist_outlined, label: 'Lavender'),
                    SizedBox(width: 12),
                    _IngredientCard(icon: Icons.eco_outlined, label: 'Aloe Vera'),
                    SizedBox(width: 12),
                    _IngredientCard(icon: Icons.water_drop_outlined, label: 'Vitamin E'),
                    SizedBox(width: 12),
                    _IngredientCard(icon: Icons.spa_outlined, label: 'Chamomile'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ---- Deskripsi ----
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Deskripsi', style: RimiTypography.titleLarge.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Text(
                      product.description ?? 'Diformulasikan secara khusus dengan kelembutan ekstra untuk kulit sensitif bayi Anda. Diperkaya dengan ekstrak alami yang memberikan efek menenangkan.',
                      style: RimiTypography.bodyMedium.copyWith(color: RimiColors.textSecondary, height: 1.5),
                    ),
                    const SizedBox(height: 10),
                    _Bullet(text: 'Tekstur ringan dan cepat meresap'),
                    _Bullet(text: 'Menjaga kelembaban hingga 24 jam'),
                    _BulletRich(spans: [
                      const TextSpan(text: 'Bebas '),
                      TextSpan(text: 'paraben', style: RimiTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700, color: RimiColors.textPrimary)),
                      const TextSpan(text: ' dan '),
                      TextSpan(text: 'pewarna buatan', style: RimiTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700, color: RimiColors.textPrimary)),
                    ]),
                    _Bullet(text: 'pH seimbang untuk kulit bayi'),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        'Baca Selengkapnya',
                        style: RimiTypography.labelMedium.copyWith(color: const Color(0xFF2979FF)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1, thickness: 1, color: RimiColors.border, indent: 16, endIndent: 16),
              const SizedBox(height: 16),

              // ---- Ulasan ----
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(child: Text('Ulasan Pembeli', style: RimiTypography.titleLarge.copyWith(fontWeight: FontWeight.w700))),
                    Text('120 Ulasan', style: RimiTypography.labelMedium.copyWith(color: const Color(0xFF2979FF))),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: RimiColors.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ...List.generate(5, (_) => const Icon(Icons.star_rounded, color: RimiColors.tertiary, size: 14)),
                          const SizedBox(width: 8),
                          RichText(
                            text: TextSpan(
                              text: 'oleh ',
                              style: RimiTypography.bodySmall.copyWith(color: RimiColors.textSecondary),
                              children: [
                                TextSpan(text: 'Bunda Sarah', style: RimiTypography.labelMedium.copyWith(fontWeight: FontWeight.w700, color: RimiColors.textPrimary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '"Wanginya lembut sekali, anakku jadi lebih tenang tidurnya. Recommended!"',
                        style: RimiTypography.bodyMedium.copyWith(fontStyle: FontStyle.italic, color: const Color(0xFF444444)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 100), // spacer for bottom bar
            ],
          ),
        ),
      ),
      bottomNavigationBar: productAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
        data: (product) => Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: RimiColors.border)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, -2)),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                _QtyButton(icon: Icons.remove, onTap: _qty > 1 ? () => setState(() => _qty--) : null),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text('$_qty', style: RimiTypography.titleMedium.copyWith(fontWeight: FontWeight.w700)),
                ),
                _QtyButton(icon: Icons.add, onTap: () => setState(() => _qty++)),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async {
                      await api.addToCart(productId: widget.productId, qty: _qty);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('✅ Ditambahkan ke keranjang')),
                        );
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: RimiColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                    label: Text('Masukkan Keranjang', style: RimiTypography.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatRp(int amount) =>
      'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
}

class _ImageCarousel extends StatelessWidget {
  const _ImageCarousel({required this.images, required this.activeIndex, required this.onChanged});
  final List<String> images;
  final int activeIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final total = images.isEmpty ? 5 : images.length;
    return Container(
      height: 300,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF5F0E8), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          PageView.builder(
            itemCount: total,
            onPageChanged: onChanged,
            itemBuilder: (context, i) {
              if (images.isEmpty) {
                return Center(
                  child: Icon(Icons.image_outlined, size: 100, color: RimiColors.neutralMuted.withValues(alpha: 0.4)),
                );
              }
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Image.network(
                  images[i],
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      Icon(Icons.image_outlined, size: 100, color: RimiColors.neutralMuted.withValues(alpha: 0.4)),
                ),
              );
            },
          ),
          Positioned(
            bottom: 16, left: 0, right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(total, (i) {
                final active = i == activeIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 18 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: active ? RimiColors.primaryDeep : RimiColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustChip extends StatelessWidget {
  const _TrustChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F7F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_rounded, size: 14, color: RimiColors.primaryDeep),
          const SizedBox(width: 4),
          Text(label, style: RimiTypography.labelSmall.copyWith(color: RimiColors.primaryDeep, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _IngredientCard extends StatelessWidget {
  const _IngredientCard({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F5FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: const Color(0xFF5B9BD5)),
          const SizedBox(height: 6),
          Text(label, style: RimiTypography.labelSmall.copyWith(fontSize: 11, fontWeight: FontWeight.w500), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 14, height: 1.5)),
          Expanded(child: Text(text, style: RimiTypography.bodyMedium.copyWith(color: RimiColors.textSecondary, height: 1.5))),
        ],
      ),
    );
  }
}

class _BulletRich extends StatelessWidget {
  const _BulletRich({required this.spans});
  final List<InlineSpan> spans;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 14, height: 1.5)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: RimiTypography.bodyMedium.copyWith(color: RimiColors.textSecondary, height: 1.5),
                children: spans,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: CircleBorder(side: BorderSide(color: onTap == null ? RimiColors.border : RimiColors.neutralMuted)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 36, height: 36,
          child: Icon(icon, size: 18, color: onTap == null ? RimiColors.border : RimiColors.neutral),
        ),
      ),
    );
  }
}

final productDetailProvider = FutureProvider.family<Product, String>((ref, id) async {
  final api = ref.watch(apiClientProvider);
  return api.getProduct(id);
});
