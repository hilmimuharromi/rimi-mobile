import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/api/api_client.dart';
import '../../../core/theme/rimi_colors.dart';
import '../../../core/theme/rimi_typography.dart';
import '../../../shared/models/product.dart';
import '../../../shared/widgets/product_card.dart';
import '../../../shared/widgets/rimi_banner_carousel.dart';
import '../../auth/providers/auth_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final productsAsync = ref.watch(homeProductsProvider);
    final categoriesAsync = ref.watch(homeCategoriesProvider);
    final name = auth.user?.displayName.split(' ').first ?? 'Moms';

    return Scaffold(
      backgroundColor: RimiColors.background,
      body: RefreshIndicator(
        color: RimiColors.primaryDeep,
        onRefresh: () async {
          ref.invalidate(homeProductsProvider);
          ref.invalidate(homeCategoriesProvider);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _HomeHeader(name: name)),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            const SliverToBoxAdapter(
              child: RimiBannerCarousel(
                items: [
                  BannerItem(
                    title: 'Cashback weekday',
                    subtitle: 'Belanja hari kerja, poin ekstra!',
                    color: RimiColors.primary,
                    icon: Icons.savings_rounded,
                  ),
                  BannerItem(
                    title: 'Ajak teman',
                    subtitle: 'Dapat 5.000 poin referral',
                    color: Color(0xFFFFE4DE),
                    icon: Icons.group_add_rounded,
                  ),
                  BannerItem(
                    title: 'Flash herbal',
                    subtitle: 'Diskon hingga 30%',
                    color: Color(0xFFFFF3D6),
                    icon: Icons.local_fire_department_rounded,
                  ),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('Kategori', style: RimiTypography.titleLarge),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: categoriesAsync.when(
                loading: () => const SizedBox(
                  height: 88,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(apiErrorMessage(e), style: RimiTypography.bodySmall),
                ),
                data: (cats) => SizedBox(
                  height: 96,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: cats.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, i) {
                      final c = cats[i];
                      return _CategoryChip(name: c.name, icon: _categoryIcon(c.slug));
                    },
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(child: Text('Produk unggulan', style: RimiTypography.titleLarge)),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Lihat semua',
                        style: RimiTypography.labelLarge.copyWith(color: RimiColors.primaryDeep),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            productsAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(apiErrorMessage(e)),
                ),
              ),
              data: (products) => SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.68,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final p = products[i];
                      return ProductCard(
                        product: p,
                        onTap: () => context.push('/product/${p.id}'),
                      );
                    },
                    childCount: products.length,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(String slug) {
    switch (slug) {
      case 'suplemen':
        return Icons.medication_liquid_rounded;
      case 'vitamin':
        return Icons.science_rounded;
      case 'perawatan':
        return Icons.spa_rounded;
      case 'snack-sehat':
        return Icons.cookie_rounded;
      case 'susu-olahan':
        return Icons.local_drink_rounded;
      case 'minuman':
        return Icons.emoji_food_beverage_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}

final homeProductsProvider = FutureProvider<List<Product>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final page = await api.listProducts(limit: 10);
  return page.items;
});

final homeCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  final api = ref.watch(apiClientProvider);
  return api.listCategories();
});

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [RimiColors.primary, Color(0xFFE8F6FF), RimiColors.background],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hai, $name 👋', style: RimiTypography.headlineMedium),
                      const SizedBox(height: 4),
                      Text(
                        'Si Rimi siap bantu belanja bayi hari ini',
                        style: RimiTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  style: IconButton.styleFrom(
                    backgroundColor: RimiColors.white,
                    foregroundColor: RimiColors.neutral,
                  ),
                  icon: const Icon(Icons.notifications_none_rounded),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              readOnly: true,
              onTap: () {},
              decoration: InputDecoration(
                hintText: 'Cari madu, susu, sabun bayi…',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: RimiColors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.name, required this.icon});
  final String name;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: RimiColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RimiColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: RimiColors.primary.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: RimiColors.primaryDeep, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: RimiTypography.labelSmall,
          ),
        ],
      ),
    );
  }
}

// ignore unused intl import helper for later
final _idr = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
// silence unused for now — used in product card
// ignore: unnecessary_statements
void _keepIntl() => _idr;
