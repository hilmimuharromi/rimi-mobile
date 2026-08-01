import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_client.dart';
import '../../../core/theme/rimi_colors.dart';
import '../../../core/theme/rimi_typography.dart';
import '../../../shared/widgets/rimi_mark.dart';
import '../../../shared/models/product.dart';
import '../../../shared/widgets/product_card.dart';
import '../../../shared/providers/wallet_provider.dart';
import '../../auth/providers/auth_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _bannerController = PageController(viewportFraction: 0.92);
  int _bannerIndex = 0;

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final productsAsync = ref.watch(homeProductsProvider);
    final balanceAsync = ref.watch(walletBalanceProvider);
    final name = auth.user?.displayName.split(' ').first ?? 'Bundo';

    return Scaffold(
      backgroundColor: RimiColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: RimiColors.primary,
          onRefresh: () async {
            ref.invalidate(homeProductsProvider);
            ref.invalidate(walletBalanceProvider);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ---------- Top App Bar ----------
              SliverToBoxAdapter(child: _TopAppBar()),
              // ---------- Greeting + Mascot ----------
              SliverToBoxAdapter(child: _GreetingRow(name: name)),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              // ---------- Search ----------
              const SliverToBoxAdapter(child: _SearchBar()),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              // ---------- Hero Banner ----------
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 160,
                  child: PageView(
                    controller: _bannerController,
                    onPageChanged: (i) => setState(() => _bannerIndex = i),
                    children: const [
                      _HeroBanner(
                        badge: 'Program Spesial',
                        title: 'Ajak Teman,\nDapat Saldo Poinku!',
                        cta: 'Bagikan Sekarang',
                        gradient: [RimiColors.heroStart, RimiColors.heroEnd],
                      ),
                      _HeroBanner(
                        badge: 'Cashback',
                        title: 'Belanja Weekday,\nPoin Ekstra!',
                        cta: 'Belanja Sekarang',
                        gradient: [Color(0xFF2ABFA4), Color(0xFF7BD8C4)],
                      ),
                      _HeroBanner(
                        badge: 'Flash Sale',
                        title: 'Diskon Herbal\nHingga 30%',
                        cta: 'Lihat Promo',
                        gradient: [Color(0xFFFFC24B), Color(0xFFFFE59D)],
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    final active = i == _bannerIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: active ? 18 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: active ? RimiColors.neutral : RimiColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // ---------- Saldo Poinku Card ----------
              SliverToBoxAdapter(child: _PoinkuCard(balanceAsync: balanceAsync)),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // ---------- Semua Produk (campur) ----------
              SliverToBoxAdapter(
                child: _SectionHeader(title: 'Semua Produk', onSeeAll: () {}),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              _ProductGrid(
                productsAsync: productsAsync,
                cashbackColor: RimiColors.secondary,
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------- TOP APP BAR --------------------
class _TopAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 4),
      child: Row(
        children: [
          const Icon(Icons.menu_rounded, size: 26, color: RimiColors.neutral),
          const SizedBox(width: 10),
          const RimiLogoLockup(markSize: 28, fontSize: 20),
          const Spacer(),
          Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_none_rounded, size: 26, color: RimiColors.neutral),
              Positioned(
                right: -1, top: 0,
                child: Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(color: RimiColors.error, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          GestureDetector(
            onTap: () => context.push('/cart'),
            child: const Icon(Icons.shopping_bag_outlined, size: 26, color: RimiColors.neutral),
          ),
        ],
      ),
    );
  }
}

// -------------------- GREETING --------------------
class _GreetingRow extends StatelessWidget {
  const _GreetingRow({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Halo, ',
                    style: RimiTypography.headlineMedium.copyWith(fontWeight: FontWeight.w500),
                    children: [
                      TextSpan(
                        text: '$name!',
                        style: RimiTypography.headlineMedium.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text('Cari kebutuhan si kecil hari ini?', style: RimiTypography.bodyMedium),
              ],
            ),
          ),
          // Si Rimi mascot (CustomPaint)
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: RimiColors.cloud,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: RimiColors.navy.withValues(alpha: 0.10),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: RimiMark(size: 44),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------- SEARCH BAR --------------------
class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: RimiColors.border),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            const Icon(Icons.search_rounded, size: 20, color: RimiColors.neutralMuted),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Cari sabun bayi, popok, atau mainan...',
                style: RimiTypography.bodyMedium.copyWith(color: RimiColors.neutralMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------- HERO BANNER --------------------
class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.badge,
    required this.title,
    required this.cta,
    required this.gradient,
  });
  final String badge;
  final String title;
  final String cta;
  final List<Color> gradient;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.fromLTRB(18, 16, 12, 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: RimiColors.secondaryDeep,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge,
                      style: RimiTypography.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 10),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: RimiTypography.headlineSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w700, height: 1.2),
                  ),
                  const SizedBox(height: 10),
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          cta,
                          style: RimiTypography.labelMedium.copyWith(color: RimiColors.secondaryDeep, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Mascot Si Rimi
            const SizedBox(
              width: 96, height: 96,
              child: RimiMark(size: 80, showCheeks: false),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------- SECTION HEADER --------------------
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.onSeeAll});
  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: RimiTypography.titleLarge.copyWith(fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
            child: Text('Lihat Semua', style: RimiTypography.labelMedium.copyWith(color: RimiColors.secondary)),
          ),
        ],
      ),
    );
  }
}

// -------------------- PRODUCT GRID (mixed) --------------------
class _ProductGrid extends StatelessWidget {
  const _ProductGrid({
    required this.productsAsync,
    required this.cashbackColor,
  });
  final AsyncValue<List<Product>> productsAsync;
  final Color cashbackColor;

  @override
  Widget build(BuildContext context) {
    return productsAsync.when(
      loading: () => const SliverToBoxAdapter(
        child: Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator())),
      ),
      error: (e, _) => SliverToBoxAdapter(
        child: Padding(padding: const EdgeInsets.all(20), child: Text(apiErrorMessage(e))),
      ),
      data: (products) {
        if (products.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(padding: EdgeInsets.all(20), child: Text('Belum ada produk')),
          );
        }
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.66,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final p = products[i];
                return ProductCard(
                  product: p,
                  cashbackColor: cashbackColor,
                  onTap: () => context.push('/product/${p.id}'),
                );
              },
              childCount: products.length,
            ),
          ),
        );
      },
    );
  }
}

// -------------------- POINKU CARD (live wallet) --------------------
class _PoinkuCard extends StatelessWidget {
  const _PoinkuCard({required this.balanceAsync});
  final AsyncValue<int> balanceAsync;

  @override
  Widget build(BuildContext context) {
    final pts = balanceAsync.maybeWhen(
      data: (b) => fmtPoints(b),
      orElse: () => '...',
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [RimiColors.secondary, RimiColors.secondaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Saldo Poinku', style: RimiTypography.labelMedium.copyWith(color: Colors.white)),
                  const SizedBox(height: 2),
                  Text('$pts pts', style: RimiTypography.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                  Text('Tukar hadiah menarik!', style: RimiTypography.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.9))),
                ],
              ),
            ),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Text('Redeem', style: RimiTypography.labelMedium.copyWith(color: RimiColors.secondary, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------- PROVIDERS --------------------
final homeProductsProvider = FutureProvider<List<Product>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final page = await api.listProducts(limit: 20);
  return page.items;
});

final homeCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  final api = ref.watch(apiClientProvider);
  return api.listCategories();
});
