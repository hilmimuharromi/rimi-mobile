import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/theme/rimi_colors.dart';
import '../../../core/theme/rimi_typography.dart';
import '../../../shared/widgets/rimi_mark.dart';
import '../../../shared/providers/wallet_provider.dart';

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

String _fmt(int n) => fmtPoints(n);

class RewardsPage extends ConsumerWidget {
  const RewardsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(redemptionCatalogProvider);
    final balanceAsync = ref.watch(walletBalanceProvider);
    final txAsync = ref.watch(walletTransactionsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: const Padding(
          padding: EdgeInsets.only(left: 20),
          child: RimiLogoLockup(markSize: 24, fontSize: 18),
        ),
        title: const SizedBox(),
        centerTitle: false,
        actions: [
          IconButton(icon: const Icon(Icons.shopping_bag_outlined, color: RimiColors.neutral), onPressed: () {}),
        ],
      ),
      body: RefreshIndicator(
        color: RimiColors.primary,
        onRefresh: () async {
          ref.invalidate(walletBalanceProvider);
          ref.invalidate(walletTransactionsProvider);
          ref.invalidate(redemptionCatalogProvider);
        },
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // ---- Balance card (LIVE) ----
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
                                  color: RimiColors.tertiaryDark,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                  fontSize: 11)),
                          const SizedBox(height: 4),
                          balanceAsync.when(
                            loading: () => _bigText('… Poin'),
                            error: (_, __) => _bigText('0 Poin'),
                            data: (b) => _bigText('${_fmt(b)} Poin'),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: balanceAsync.when(
                              loading: () => _smallText('Estimasi: —'),
                              error: (_, __) => _smallText('Estimasi: Rp 0'),
                              data: (b) => _smallText('Estimasi: Rp ${_fmt((b / 10).round())}'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.workspace_premium_rounded, size: 44, color: Color(0xFFE5A830)),
                  ],
                ),
              ),
            ),

            // ---- Tukar Voucher header ----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                      child: Text('Tukar Voucher',
                          style: RimiTypography.titleLarge.copyWith(fontWeight: FontWeight.w800))),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ---- Voucher list (LIVE — filtered by type=voucher) ----
            SizedBox(
              height: 92,
              child: catalogAsync.when(
                loading: () => const Center(
                    child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))),
                error: (_, __) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Gagal memuat voucher',
                      style: RimiTypography.bodySmall.copyWith(color: RimiColors.error)),
                ),
                data: (items) {
                  final vouchers = items.where((v) =>
                      (v['type']?.toString() ?? '').toLowerCase().contains('voucher')).toList();
                  if (vouchers.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Belum ada voucher', style: RimiTypography.bodySmall),
                    );
                  }
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: vouchers.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) {
                      final v = vouchers[i];
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

            // ---- Hadiah Utama (LIVE — filtered by type != voucher) ----
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
                            color: const Color(0xFF2D6A4F),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            catalogAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                    child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))),
              ),
              error: (_, __) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('Gagal memuat hadiah',
                    style: RimiTypography.bodySmall.copyWith(color: RimiColors.error)),
              ),
              data: (items) {
                final prizes = items.where((v) =>
                    !(v['type']?.toString() ?? '').toLowerCase().contains('voucher')).toList();
                if (prizes.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Belum ada hadiah utama', style: RimiTypography.bodySmall),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: prizes.length,
                    itemBuilder: (_, i) {
                      final p = prizes[i];
                      final type = p['type']?.toString() ?? 'product';
                      final iconData = _iconFor(type);
                      return _PrizeCard(
                        icon: iconData,
                        badge: type.toUpperCase(),
                        badgeColor: _bgFor(i),
                        name: p['name']?.toString() ?? 'Hadiah',
                        price: '${(p['points_cost'] as num?)?.toInt() ?? 0} Poin',
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // ---- Riwayat Poin (LIVE) ----
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
            txAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
              ),
              error: (_, __) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Gagal memuat riwayat',
                    style: RimiTypography.bodySmall.copyWith(color: RimiColors.error)),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Belum ada transaksi poin', style: RimiTypography.bodySmall),
                  );
                }
                return Column(children: items.take(8).map(_txTile).toList());
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _txTile(Map<String, dynamic> t) {
    final type = t['type']?.toString() ?? '';
    final amountRaw = (t['amount'] as num?)?.toInt() ?? 0;
    // Convention: type contains 'credit' or 'debit' or specific labels
    final isCredit = type.contains('credit') || amountRaw > 0;
    final amount = isCredit ? amountRaw.abs() : -amountRaw.abs();
    final title = t['description']?.toString() ?? _titleForType(type);
    final createdAt = t['created_at']?.toString() ?? '';
    final date = _formatDate(createdAt);

    final iconData = _txIcon(type);
    final bg = _txIconBg(type);
    final fg = _txIconFg(type);
    final amountText = '${amount >= 0 ? '+' : '-'}${_fmt(amount.abs())}';

    return _HistoryTile(
      icon: iconData,
      iconBg: bg,
      iconColor: fg,
      title: title,
      date: date,
      amount: amountText,
      positive: amount >= 0,
    );
  }

  String _titleForType(String t) {
    if (t.contains('cashback')) return 'Cashback Belanja';
    if (t.contains('redemption') || t.contains('redeem')) return 'Tukar Reward';
    if (t.contains('referral')) return 'Bonus Referral';
    return 'Transaksi Poin';
  }

  IconData _txIcon(String t) {
    if (t.contains('cashback') || t.contains('credit_order')) return Icons.shopping_bag_outlined;
    if (t.contains('redemption') || t.contains('debit')) return Icons.card_giftcard_rounded;
    if (t.contains('referral')) return Icons.person_add_rounded;
    return Icons.stars_rounded;
  }

  Color _txIconBg(String t) {
    if (t.contains('cashback')) return const Color(0xFFF5EAD6);
    if (t.contains('redemption') || t.contains('debit')) return const Color(0xFFFCE4EC);
    if (t.contains('referral')) return const Color(0xFFE8F1FD);
    return const Color(0xFFF5F5F5);
  }

  Color _txIconFg(String t) {
    if (t.contains('cashback')) return const Color(0xFFB5883A);
    if (t.contains('redemption') || t.contains('debit')) return const Color(0xFFE91E63);
    if (t.contains('referral')) return const Color(0xFF2979FF);
    return const Color(0xFF757575);
  }

  String _formatDate(String iso) {
    if (iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year} • ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  Widget _bigText(String s) => Text(s,
      style: RimiTypography.headlineMedium
          .copyWith(color: RimiColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 22));

  Widget _smallText(String s) =>
      Text(s, style: RimiTypography.labelSmall.copyWith(fontSize: 11, fontWeight: FontWeight.w600));

  IconData _iconFor(String type) {
    switch (type) {
      case 'voucher':
        return Icons.local_offer_rounded;
      case 'shipping':
        return Icons.local_shipping_rounded;
      case 'cashback':
        return Icons.percent_rounded;
      case 'product':
        return Icons.card_giftcard_rounded;
      default:
        return Icons.card_giftcard_rounded;
    }
  }

  Color _bgFor(int i) {
    const palette = [
      Color(0xFFCFF0E8),
      Color(0xFFFFE59D),
      Color(0xFFFDCFB0),
      Color(0xFFE8F1FD),
    ];
    return palette[i % palette.length];
  }

  Color _fgFor(int i) {
    const palette = [
      RimiColors.primaryDeep,
      RimiColors.tertiaryDark,
      RimiColors.secondary,
      Color(0xFF2979FF),
    ];
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
      width: 160,
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
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(points,
                    style: RimiTypography.labelSmall.copyWith(
                        color: RimiColors.secondary, fontWeight: FontWeight.w700, fontSize: 11)),
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
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: Text(badge,
                      style: RimiTypography.labelSmall.copyWith(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3)),
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
                    style: RimiTypography.labelMedium
                        .copyWith(color: RimiColors.primaryDeep, fontWeight: FontWeight.w700)),
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
                Text(title,
                    style: RimiTypography.labelLarge.copyWith(fontWeight: FontWeight.w700), maxLines: 1),
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
