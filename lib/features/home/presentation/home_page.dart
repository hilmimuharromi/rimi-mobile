import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/api/api_client.dart';
import '../../../core/theme/rimi_colors.dart';
import '../../../core/theme/rimi_typography.dart';
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
  final _bannerController = PageController(viewportFraction: 1.0);
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
    final categoriesAsync = ref.watch(homeCategoriesProvider);
    final balanceAsync = ref.watch(walletBalanceProvider);
    final referralCountAsync = ref.watch(referralCountProvider);
    final bannersAsync = ref.watch(homeBannersProvider);
    final name = auth.user?.displayName.split(' ').first ?? 'Bundo';

    return Scaffold(
      backgroundColor: RimiColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: RimiColors.primary,
          onRefresh: () async {
            ref.invalidate(homeProductsProvider);
            ref.invalidate(homeCategoriesProvider);
            ref.invalidate(walletBalanceProvider);
            ref.invalidate(referralCountProvider);
            ref.invalidate(homeBannersProvider);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ---------- Search + Notif + Cart ----------
              SliverToBoxAdapter(child: _TopBar(name: name)),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // ---------- Banner Carousel ----------
              SliverToBoxAdapter(
                child: _BannerCarousel(
                  bannersAsync: bannersAsync,
                  controller: _bannerController,
                  index: _bannerIndex,
                  onChanged: (i) => setState(() => _bannerIndex = i),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // ---------- Poin + Referral pill badges ----------
              SliverToBoxAdapter(
                child: _PillBadges(
                  balanceAsync: balanceAsync,
                  referralCountAsync: referralCountAsync,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // ---------- Kategori Populer ----------
              SliverToBoxAdapter(
                child: _SectionTitle(title: 'Kategori Populer'),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverToBoxAdapter(
                child: _CategoryStrip(categoriesAsync: categoriesAsync),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // ---------- Rekomendasi Produk ----------
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: 'Rekomendasi Produk',
                  onSeeAll: () => context.push('/products'),
                ),
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

// -------------------- TOP BAR (search + notif + cart) --------------------
class _TopBar extends StatelessWidget {
  const _TopBar({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          // Search bar
          Expanded(
            child: GestureDetector(
              onTap: () => context.push('/search'),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: RimiColors.navy.withValues(alpha: 0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    const Icon(Icons.search_rounded, size: 20, color: RimiColors.neutralMuted),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Cari kebutuhan si kecil...',
                        style: RimiTypography.bodyMedium.copyWith(color: RimiColors.neutralMuted),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Notifications
          GestureDetector(
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: RimiColors.navy.withValues(alpha: 0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(Icons.notifications_none_rounded, size: 24, color: RimiColors.primary),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: RimiColors.secondary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Cart
          GestureDetector(
            onTap: () => context.push('/cart'),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: RimiColors.navy.withValues(alpha: 0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.shopping_cart_outlined, size: 24, color: RimiColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------- BANNER CAROUSEL (from BE, fallback default) --------------------
class _BannerCarousel extends StatelessWidget {
  const _BannerCarousel({
    required this.bannersAsync,
    required this.controller,
    required this.index,
    required this.onChanged,
  });

  final AsyncValue<List<Map<String, dynamic>>> bannersAsync;
  final PageController controller;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return bannersAsync.when(
      loading: () => const SizedBox(height: 160, child: Center(child: CircularProgressIndicator())),
      error: (_, __) => _defaultBanner(controller, index, onChanged),
      data: (banners) {
        if (banners.isEmpty) return _defaultBanner(controller, index, onChanged);
        return _buildFromApi(banners, controller, index, onChanged);
      },
    );
  }

  Widget _defaultBanner(PageController controller, int index, ValueChanged<int> onChanged) {
    final banners = [
      _BannerData(
        badge: 'Program Spesial',
        title: 'Ajak Teman,\nDapat Saldo Poinku!',
        cta: 'Bagikan Sekarang',
        gradient: const [RimiColors.coral, RimiColors.coralDark],
        icon: Icons.group_rounded,
      ),
      _BannerData(
        badge: 'Cashback',
        title: 'Belanja Weekday,\nPoin Ekstra!',
        cta: 'Belanja Sekarang',
        gradient: const [Color(0xFF2ABFA4), Color(0xFF7BD8C4)],
        icon: Icons.local_offer_rounded,
      ),
      _BannerData(
        badge: 'Flash Sale',
        title: 'Diskon Herbal\nHingga 30%',
        cta: 'Lihat Promo',
        gradient: const [Color(0xFFFFC24B), Color(0xFFFFE59D)],
        icon: Icons.flash_on_rounded,
      ),
    ];
    return _buildBanner(banners, controller, index, onChanged);
  }

  Widget _buildFromApi(
    List<Map<String, dynamic>> raw,
    PageController controller,
    int index,
    ValueChanged<int> onChanged,
  ) {
    final banners = raw.map((b) {
      final link = b['link_url'] as String? ?? '';
      final data = _BannerData(
        badge: b['badge'] as String? ?? 'Promo',
        title: b['title'] as String? ?? '',
        cta: b['cta'] as String? ?? 'Lihat',
        gradient: [
          Color(int.tryParse('0xFF${(b['color_start'] as String?)?.replaceAll('#', '')}') ?? 0xFFF97A6D),
          Color(int.tryParse('0xFF${(b['color_end'] as String?)?.replaceAll('#', '')}') ?? 0xFFE15A4C),
        ],
        icon: Icons.campaign_rounded,
        imageUrl: b['image_url'] as String?,
        linkUrl: link,
      );
      return data;
    }).toList();
    return _buildBanner(banners, controller, index, onChanged);
  }

  Widget _buildBanner(
    List<_BannerData> banners,
    PageController controller,
    int index,
    ValueChanged<int> onChanged,
  ) {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView(
            controller: controller,
            onPageChanged: onChanged,
            children: banners.map((b) => _HeroBanner(data: b)).toList(),
          ),
        ),
        const SizedBox(height: 8),
        // Pagination dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(banners.length, (i) {
            final active = i == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 18 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: active ? RimiColors.secondary : RimiColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// -------------------- HERO BANNER --------------------
class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.data});
  final _BannerData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: data.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: data.gradient.first.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background icon decoration
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                data.icon,
                size: 160,
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      data.badge,
                      style: GoogleFontsQuicksand.labelSm(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data.title,
                    style: GoogleFontsQuicksand.headlineLgMobile(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        if (data.linkUrl != null && data.linkUrl!.isNotEmpty) {
                          context.push(data.linkUrl!);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          data.cta,
                          style: GoogleFontsPlusJakarta.labelLg(
                            color: RimiColors.coral,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------- PILL BADGES (Poin + Referral) --------------------
class _PillBadges extends StatelessWidget {
  const _PillBadges({required this.balanceAsync, required this.referralCountAsync});
  final AsyncValue<int> balanceAsync;
  final AsyncValue<int> referralCountAsync;

  @override
  Widget build(BuildContext context) {
    final pts = balanceAsync.maybeWhen(
      data: (b) => fmtPoints(b),
      orElse: () => '...',
    );
    final refCount = referralCountAsync.maybeWhen(
      data: (n) => '$n Teman',
      orElse: () => '...',
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Total Poin badge
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: RimiColors.navy.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(color: RimiColors.tertiary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: RimiColors.tertiary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.star_rounded, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTAL POIN',
                        style: GoogleFontsPlusJakarta.labelSm(
                          color: RimiColors.textSecondary,
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        pts,
                        style: GoogleFontsQuicksand.headlineMd(
                          color: RimiColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Referral badge
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: RimiColors.navy.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(color: RimiColors.primary.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: RimiColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.group_rounded, color: RimiColors.primary, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'REFERRAL',
                        style: GoogleFontsPlusJakarta.labelSm(
                          color: RimiColors.textSecondary,
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        refCount,
                        style: GoogleFontsQuicksand.headlineMd(
                          color: RimiColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------- SECTION TITLE --------------------
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: GoogleFontsQuicksand.headlineMd(
          color: RimiColors.primary,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
    );
  }
}

// -------------------- CATEGORY STRIP --------------------
class _CategoryStrip extends StatelessWidget {
  const _CategoryStrip({required this.categoriesAsync});
  final AsyncValue<List<Category>> categoriesAsync;

  // Fallback static categories if API returns empty
  static const _fallbackCategories = [
    _CatData(icon: Icons.child_care_rounded, label: 'Popok', color: Color(0xFFE3F0FB), iconColor: RimiColors.primary),
    _CatData(icon: Icons.medical_services_rounded, label: 'Susu', color: Color(0xFFFFF5E6), iconColor: RimiColors.tertiary),
    _CatData(icon: Icons.toys_rounded, label: 'Mainan', color: Color(0xFFFCE8E6), iconColor: RimiColors.secondary),
    _CatData(icon: Icons.checkroom_rounded, label: 'Pakaian', color: Color(0xFFE8F5E9), iconColor: Color(0xFF2E7D32)),
    _CatData(icon: Icons.soap_rounded, label: 'Perawatan', color: Color(0xFFF3E5F5), iconColor: Color(0xFF7B1FA2)),
    _CatData(icon: Icons.grid_view_rounded, label: 'Lainnya', color: RimiColors.surface, iconColor: RimiColors.neutralMuted),
  ];

  @override
  Widget build(BuildContext context) {
    return categoriesAsync.when(
      loading: () => const SizedBox(height: 80),
      error: (_, __) => _buildStrip(_fallbackCategories, context),
      data: (cats) {
        if (cats.isEmpty) return _buildStrip(_fallbackCategories, context);
        // Map API categories to display data using fallback colors
        final mapped = <_CatData>[];
        for (var i = 0; i < cats.length; i++) {
          final fc = _fallbackCategories[i % _fallbackCategories.length];
          mapped.add(_CatData(
            icon: fc.icon,
            label: cats[i].name,
            color: fc.color,
            iconColor: fc.iconColor,
          ));
        }
        return _buildStrip(mapped, context);
      },
    );
  }

  Widget _buildStrip(List<_CatData> cats, BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 20),
        itemBuilder: (_, i) {
          final c = cats[i];
          return GestureDetector(
            onTap: () => context.push('/products'),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: c.color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(c.icon, color: c.iconColor, size: 28),
                ),
                const SizedBox(height: 6),
                Text(
                  c.label,
                  style: GoogleFontsPlusJakarta.labelSm(
                    color: RimiColors.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// -------------------- SECTION HEADER (with see all) --------------------
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.onSeeAll});
  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFontsQuicksand.headlineMd(
                color: RimiColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ),
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
            child: Text(
              'Lihat Semua',
              style: GoogleFontsPlusJakarta.labelLg(
                color: RimiColors.secondary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------- PRODUCT GRID --------------------
class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.productsAsync, required this.cashbackColor});
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
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

// -------------------- DATA CLASSES --------------------
class _BannerData {
  const _BannerData({
    required this.badge,
    required this.title,
    required this.cta,
    required this.gradient,
    required this.icon,
    this.imageUrl,
    this.linkUrl,
  });
  final String badge;
  final String title;
  final String cta;
  final List<Color> gradient;
  final IconData icon;
  final String? imageUrl;
  final String? linkUrl;
}

class _CatData {
  const _CatData({
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
  });
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
}

// -------------------- FONT HELPERS --------------------
/// Direct GoogleFonts helpers matching DESIGN.md Quicksand + Plus Jakarta Sans specs.
class GoogleFontsQuicksand {
  static TextStyle headlineLgMobile({
    Color? color,
    FontWeight? fontWeight,
    double? height,
  }) =>
      GoogleFonts.quicksand(
        fontSize: 22,
        fontWeight: fontWeight ?? FontWeight.w700,
        color: color,
        height: height,
      );

  static TextStyle headlineMd({
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) =>
      GoogleFonts.quicksand(
        fontSize: fontSize ?? 20,
        fontWeight: fontWeight ?? FontWeight.w600,
        color: color,
      );

  static TextStyle labelSm({
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) =>
      GoogleFonts.quicksand(
        fontSize: fontSize ?? 12,
        fontWeight: fontWeight ?? FontWeight.w500,
        color: color,
      );
}

class GoogleFontsPlusJakarta {
  static TextStyle labelSm({
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: fontSize ?? 12,
        fontWeight: fontWeight ?? FontWeight.w500,
        color: color,
      );

  static TextStyle labelLg({
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: fontSize ?? 14,
        fontWeight: fontWeight ?? FontWeight.w600,
        color: color,
      );
}

// -------------------- PROVIDERS --------------------
final homeProductsProvider = FutureProvider<List<Product>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final page = await api.listProducts(limit: 20, featured: true);
  return page.items;
});

final homeCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  final api = ref.watch(apiClientProvider);
  return api.listCategories();
});

final homeBannersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final api = ref.watch(apiClientProvider);
  try {
    return await api.listBanners(position: 'home');
  } catch (_) {
    return <Map<String, dynamic>>[];
  }
});

/// Referral downline count for badge display.
final referralCountProvider = FutureProvider<int>((ref) async {
  final api = ref.watch(apiClientProvider);
  try {
    final list = await api.getReferralDownline(limit: 100);
    return list.length;
  } catch (_) {
    return 0;
  }
});
