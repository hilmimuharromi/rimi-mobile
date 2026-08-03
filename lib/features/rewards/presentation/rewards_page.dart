import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/api/api_client.dart';
import '../../../core/theme/rimi_colors.dart';
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
      backgroundColor: RimiColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: RimiColors.primary,
          onRefresh: () async {
            ref.invalidate(walletBalanceProvider);
            ref.invalidate(walletTransactionsProvider);
            ref.invalidate(redemptionCatalogProvider);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ---------- Top App Bar ----------
              SliverToBoxAdapter(
                child: _TopBar(),
              ),

              // ---------- Points Header (gold shimmer) ----------
              SliverToBoxAdapter(
                child: _PointsHeader(balanceAsync: balanceAsync),
              ),

              // ---------- Tukarkan Poin ----------
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverToBoxAdapter(
                child: _SectionHeader(title: 'Tukarkan Poin'),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverToBoxAdapter(
                child: _RedeemList(catalogAsync: catalogAsync, balanceAsync: balanceAsync),
              ),

              // ---------- Riwayat Poin ----------
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverToBoxAdapter(
                child: _HistoryHeader(),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              _TransactionList(txAsync: txAsync),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------- TOP BAR --------------------
class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: RimiColors.background,
        boxShadow: [
          BoxShadow(
            color: RimiColors.cloud.withValues(alpha: 0.5),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 40),
          Text(
            'Rimi',
            style: GoogleFonts.quicksand(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: RimiColors.primary,
              letterSpacing: -0.5,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: RimiColors.primary, size: 24),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

// -------------------- POINTS HEADER (gold shimmer card) --------------------
class _PointsHeader extends StatelessWidget {
  const _PointsHeader({required this.balanceAsync});
  final AsyncValue<int> balanceAsync;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Container(
        constraints: const BoxConstraints(minHeight: 180),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFFC24B),
              Color(0xFFFFD99A),
              Color(0xFFFFC24B),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFC24B).withValues(alpha: 0.3),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Floating circles decoration
            Positioned(
              top: -16,
              left: -16,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -40,
              right: -40,
              child: Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Mascot watermark
            Positioned(
              right: -10,
              bottom: -20,
              child: Icon(
                Icons.emoji_events_rounded,
                size: 120,
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: balanceAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
                error: (_, __) => _content(0),
                data: (b) => _content(b),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(int balance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            const Icon(Icons.star_rounded, color: Color(0xFF5E4200), size: 20),
            const SizedBox(width: 8),
            Text(
              'TOTAL SALDO POIN',
              style: GoogleFonts.quicksand(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF5E4200).withValues(alpha: 0.8),
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${_fmt(balance)} Poin',
          style: GoogleFonts.quicksand(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF5E4200),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Estimasi: Rp ${_fmt((balance / 10).round())}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF5E4200),
            ),
          ),
        ),
      ],
    );
  }
}

// -------------------- SECTION HEADER --------------------
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.quicksand(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: RimiColors.textPrimary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
            child: Text(
              'Lihat Semua',
              style: GoogleFonts.quicksand(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: RimiColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------- REDEEM LIST (vertical) --------------------
class _RedeemList extends StatelessWidget {
  const _RedeemList({required this.catalogAsync, required this.balanceAsync});
  final AsyncValue<List<Map<String, dynamic>>> catalogAsync;
  final AsyncValue<int> balanceAsync;

  @override
  Widget build(BuildContext context) {
    return catalogAsync.when(
      loading: () => const Center(
        child: Padding(padding: EdgeInsets.all(24), child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))),
      ),
      error: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text('Gagal memuat katalog', style: GoogleFonts.plusJakartaSans(color: RimiColors.error, fontSize: 14)),
      ),
      data: (items) {
        if (items.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Belum ada hadiah tersedia', style: GoogleFonts.plusJakartaSans(color: RimiColors.textSecondary, fontSize: 14)),
          );
        }
        final balance = balanceAsync.maybeWhen(data: (b) => b, orElse: () => 0);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: items.map((item) => _RedeemItem(item: item, balance: balance)).toList(),
          ),
        );
      },
    );
  }
}

class _RedeemItem extends StatelessWidget {
  const _RedeemItem({required this.item, required this.balance});
  final Map<String, dynamic> item;
  final int balance;

  @override
  Widget build(BuildContext context) {
    final name = item['name']?.toString() ?? 'Hadiah';
    final cost = (item['points_cost'] as num?)?.toInt() ?? 0;
    final type = item['type']?.toString() ?? 'product';
    final canAfford = balance >= cost;

    final iconData = _iconFor(type);
    final iconBg = canAfford ? const Color(0xFFFFEDEA) : const Color(0xFFFFD99A);
    final iconColor = canAfford ? RimiColors.secondary : RimiColors.tertiary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RimiColors.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: RimiColors.cloud.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.quicksand(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: RimiColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '$cost Poin',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: canAfford ? RimiColors.secondary : RimiColors.tertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _RedeemButton(canAfford: canAfford),
        ],
      ),
    );
  }

  IconData _iconFor(String type) {
    switch (type.toLowerCase()) {
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
}

class _RedeemButton extends StatelessWidget {
  const _RedeemButton({required this.canAfford});
  final bool canAfford;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: canAfford ? RimiColors.coral : RimiColors.cloud,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        canAfford ? 'Tukar' : 'Belum Cukup',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: canAfford ? Colors.white : RimiColors.neutralMuted,
        ),
      ),
    );
  }
}

// -------------------- HISTORY HEADER --------------------
class _HistoryHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Riwayat Poin',
              style: GoogleFonts.quicksand(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: RimiColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.tune_rounded, size: 20, color: RimiColors.neutralMuted),
            onPressed: () {},
            style: IconButton.styleFrom(
              backgroundColor: RimiColors.surface,
              shape: const CircleBorder(),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------- TRANSACTION LIST --------------------
class _TransactionList extends StatelessWidget {
  const _TransactionList({required this.txAsync});
  final AsyncValue<List<Map<String, dynamic>>> txAsync;

  @override
  Widget build(BuildContext context) {
    return txAsync.when(
      loading: () => const SliverToBoxAdapter(
        child: Padding(padding: EdgeInsets.all(24), child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)))),
      ),
      error: (_, __) => const SliverToBoxAdapter(
        child: Padding(padding: EdgeInsets.all(16), child: Text('Gagal memuat riwayat')),
      ),
      data: (items) {
        if (items.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(padding: EdgeInsets.all(16), child: Text('Belum ada transaksi poin')),
          );
        }
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => _TxTile(tx: items[i]),
              childCount: items.length > 10 ? 10 : items.length,
            ),
          ),
        );
      },
    );
  }
}

class _TxTile extends StatelessWidget {
  const _TxTile({required this.tx});
  final Map<String, dynamic> tx;

  @override
  Widget build(BuildContext context) {
    final type = tx['type']?.toString() ?? '';
    final amountRaw = (tx['amount'] as num?)?.toInt() ?? 0;
    final isCredit = type.contains('credit') || amountRaw > 0;
    final amount = isCredit ? amountRaw.abs() : -amountRaw.abs();
    final title = tx['description']?.toString() ?? _titleForType(type);
    final createdAt = tx['created_at']?.toString() ?? '';
    final date = _formatDate(createdAt);

    final iconData = _txIcon(type);
    final bg = _txIconBg(type);
    final fg = _txIconFg(type);
    final amountText = '${amount >= 0 ? '+' : '-'}${_fmt(amount.abs())}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: RimiColors.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: RimiColors.cloud.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: fg, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: RimiColors.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: RimiColors.neutralMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amountText,
            style: GoogleFonts.quicksand(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: amount >= 0 ? const Color(0xFF2D6A4F) : RimiColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  String _titleForType(String t) {
    if (t.contains('cashback')) return 'Cashback Belanja';
    if (t.contains('redemption') || t.contains('redeem')) return 'Tukar Reward';
    if (t.contains('referral')) return 'Bonus Referral';
    return 'Transaksi Poin';
  }

  IconData _txIcon(String t) {
    if (t.contains('cashback') || t.contains('credit_order')) return Icons.add_shopping_cart_rounded;
    if (t.contains('redemption') || t.contains('debit')) return Icons.redeem_rounded;
    if (t.contains('referral')) return Icons.group_rounded;
    return Icons.star_rounded;
  }

  Color _txIconBg(String t) {
    if (t.contains('cashback') || t.contains('credit_order')) return RimiColors.cloud;
    if (t.contains('redemption') || t.contains('debit')) return const Color(0xFFFFEDEA);
    if (t.contains('referral')) return const Color(0xFFFFD99A);
    return const Color(0xFFF5F5F5);
  }

  Color _txIconFg(String t) {
    if (t.contains('cashback') || t.contains('credit_order')) return RimiColors.primary;
    if (t.contains('redemption') || t.contains('debit')) return RimiColors.secondary;
    if (t.contains('referral')) return RimiColors.tertiary;
    return RimiColors.neutralMuted;
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
}
