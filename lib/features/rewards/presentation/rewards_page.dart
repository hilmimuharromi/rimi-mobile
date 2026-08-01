import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/theme/rimi_colors.dart';
import '../../../core/theme/rimi_typography.dart';

/// Live catalog from BE `/api/v1/redemption/catalog` (member auth required).
final redemptionCatalogProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final api = ref.watch(apiClientProvider);
  try {
    final raw = await api.getRedemptionCatalog();
    return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  } catch (_) {
    return <Map<String, dynamic>>[];
  }
});

class RewardsPage extends ConsumerWidget {
  const RewardsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(redemptionCatalogProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Icon(Icons.menu_rounded, color: RimiColors.neutral),
        ),
        title: Text('Rimi', style: RimiTypography.headlineMedium.copyWith(fontWeight: FontWeight.w800)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: RimiColors.neutral),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ---- Points balance card ----
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFC24B), Color(0xFFFFE59D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.gps_fixed_rounded, color: RimiColors.tertiaryDark, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TOTAL SALDO POIN',
                            style: RimiTypography.labelSmall.copyWith(
                                color: RimiColors.tertiaryDark, fontWeight: FontWeight.w700, letterSpacing: 0.5, fontSize: 11)),
                        const SizedBox(height: 4),
                        Text('125.000 Poin',
                            style: RimiTypography.headlineMedium.copyWith(
                                color: RimiColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 22)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('Estimasi: Rp 12.500',
                              style: RimiTypography.labelSmall.copyWith(fontSize: 11, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.workspace_premium_rounded, size: 44, color: Color(0xFFE5A830)),
                ],
              ),
            ),
          ),

          // ---- Tukar Voucher ----
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                    child: Text('Tukar Voucher',
                        style: RimiTypography.titleLarge.copyWith(fontWeight: FontWeight.w800))),
                Text('Lihat Semua',
                    style: RimiTypography.labelMedium.copyWith(color: RimiColors.primary, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 92,
            child: catalogAsync.when(
              loading: () => const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))),
              error: (_, __) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('Gagal memuat reward', style: RimiTypography.bodySmall.copyWith(color: RimiColors.error)),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Belum ada voucher', style: RimiTypography.bodySmall),
                  );
                }
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) {
                    final v = items[i];
                    return _VoucherCard(
                      icon: _iconFor(v['type']?.toString() ?? 'voucher'),
                      iconBg: _bgFor(i),
                      iconColor: _fgFor(i),
                      label: v['name']?.toString() ?? 'Voucher',
                      points: '${(v['points_cost'] as num?)?.toInt() ?? 0} Poin',
                    );
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // ---- Hadiah Utama ----
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                    child: Text('Hadiah Utama',
                        style: RimiTypography.titleLarge.copyWith(fontWeight: FontWeight.w800))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDF1E5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('REWARD RESELLER AKTIF',
                      style: RimiTypography.labelSmall.copyWith(
                          color: const Color(0xFF2D6A4F), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _PrizeCard(
                    icon: Icons.electric_moped_rounded,
                    badge: 'BEST VALUE',
                    badgeColor: Color(0xFF2D6A4F),
                    name: 'Motor Listrik',
                    price: '2.5M Poin',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PrizeCard(
                    icon: Icons.mosque_rounded,
                    badge: 'SPIRITUAL',
                    badgeColor: Color(0xFF8B0000),
                    name: 'Paket Umroh',
                    price: '5M Poin',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ---- Riwayat Poin ----
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                    child: Text('Riwayat Poin',
                        style: RimiTypography.titleLarge.copyWith(fontWeight: FontWeight.w800))),
                const Icon(Icons.tune_rounded, size: 20, color: RimiColors.neutral),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const _HistoryTile(
            icon: Icons.shopping_bag_outlined,
            iconBg: Color(0xFFF5EAD6),
            iconColor: Color(0xFFB5883A),
            title: 'Belanja - INV/2023/102',
            date: '12 Okt 2023 • 14:20',
            amount: '+1.250',
            positive: true,
          ),
          const _HistoryTile(
            icon: Icons.card_giftcard_rounded,
            iconBg: Color(0xFFFCE4EC),
            iconColor: Color(0xFFE91E63),
            title: 'Tukar - Voucher Ongkir',
            date: '10 Okt 2023 • 09:15',
            amount: '-5.000',
            positive: false,
          ),
          const _HistoryTile(
            icon: Icons.person_add_rounded,
            iconBg: Color(0xFFF5F5F5),
            iconColor: Color(0xFF757575),
            title: 'Bonus Referral - Andi S.',
            date: '08 Okt 2023 • 18:45',
            amount: '+5.000',
            positive: true,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'voucher': return Icons.local_offer_rounded;
      case 'shipping': return Icons.local_shipping_rounded;
      case 'cashback': return Icons.percent_rounded;
      case 'product': return Icons.card_giftcard_rounded;
      default: return Icons.card_giftcard_rounded;
    }
  }

  Color _bgFor(int i) {
    const palette = [Color(0xFFCFF0E8), Color(0xFFFFE59D), Color(0xFFFDCFB0), Color(0xFFE8F1FD)];
    return palette[i % palette.length];
  }

  Color _fgFor(int i) {
    const palette = [RimiColors.primaryDeep, RimiColors.tertiaryDark, RimiColors.secondary, Color(0xFF2979FF)];
    return palette[i % palette.length];
  }
}

class _VoucherCard extends StatelessWidget {
  const _VoucherCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.points,
  });
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String points;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: RimiColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label,
                    style: RimiTypography.labelMedium.copyWith(fontWeight: FontWeight.w700, fontSize: 12),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(points,
                    style: RimiTypography.labelSmall
                        .copyWith(color: RimiColors.secondary, fontWeight: FontWeight.w700, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrizeCard extends StatelessWidget {
  const _PrizeCard({
    required this.icon,
    required this.badge,
    required this.badgeColor,
    required this.name,
    required this.price,
  });
  final IconData icon;
  final String badge;
  final Color badgeColor;
  final String name;
  final String price;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: RimiColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              Container(
                height: 100,
                color: const Color(0xFFF7F7F7),
                child: Center(child: Icon(icon, size: 56, color: RimiColors.neutralSoft)),
              ),
              Positioned(
                top: 8, left: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: const BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
                  ),
                  child: Text(badge,
                      style: RimiTypography.labelSmall
                          .copyWith(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.3)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: RimiTypography.labelLarge.copyWith(fontWeight: FontWeight.w700), maxLines: 1),
                const SizedBox(height: 4),
                Text(price,
                    style: RimiTypography.labelMedium.copyWith(color: RimiColors.primaryDeep, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: null,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFF5F5F5),
                      disabledBackgroundColor: const Color(0xFFF5F5F5),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text('Belum Cukup',
                        style: RimiTypography.labelMedium
                            .copyWith(color: RimiColors.neutralSoft, fontWeight: FontWeight.w700)),
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

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.date,
    required this.amount,
    required this.positive,
  });
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String date;
  final String amount;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: RimiTypography.labelLarge.copyWith(fontWeight: FontWeight.w700), maxLines: 1),
                const SizedBox(height: 2),
                Text(date, style: RimiTypography.bodySmall.copyWith(fontSize: 11)),
              ],
            ),
          ),
          Text(amount,
              style: RimiTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: positive ? const Color(0xFF2D6A4F) : const Color(0xFFE53935))),
        ],
      ),
    );
  }
}
