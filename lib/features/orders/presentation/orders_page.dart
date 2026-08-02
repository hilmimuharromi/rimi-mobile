import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_client.dart';
import '../../../core/theme/rimi_colors.dart';
import '../../../core/theme/rimi_typography.dart';
import '../../../shared/widgets/rimi_mark.dart';

/// Order history provider — fetches from BE `/api/v1/orders/`.
final ordersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final api = ref.watch(apiClientProvider);
  return api.listOrders(limit: 20);
});

class OrdersPage extends ConsumerWidget {
  const OrdersPage({super.key});

  String _fmtRp(int amount) =>
      'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\\d{1,3})(?=(\\d{3})+(?!\\d))'), (m) => '${m[1]}.')}';

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return RimiColors.success;
      case 'pending':
        return RimiColors.warning;
      case 'cancelled':
      case 'failed':
        return RimiColors.error;
      case 'paid':
      case 'processing':
      case 'shipped':
        return RimiColors.info;
      default:
        return RimiColors.neutralSoft;
    }
  }

  String _statusLabel(String status) {
    const labels = {
      'pending': 'Menunggu Bayar',
      'paid': 'Dibayar',
      'processing': 'Diproses',
      'shipped': 'Dikirim',
      'completed': 'Selesai',
      'cancelled': 'Dibatalkan',
      'failed': 'Gagal',
    };
    return labels[status] ?? status;
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle_rounded;
      case 'pending':
        return Icons.access_time_rounded;
      case 'cancelled':
      case 'failed':
        return Icons.cancel_rounded;
      case 'shipped':
        return Icons.local_shipping_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: RimiColors.neutral),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Riwayat Pesanan', style: TextStyle(color: RimiColors.neutral, fontWeight: FontWeight.w700)),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        color: RimiColors.secondary,
        onRefresh: () async => ref.invalidate(ordersProvider),
        child: ordersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _ErrorOrEmpty(
            icon: Icons.error_outline,
            title: 'Gagal memuat',
            subtitle: apiErrorMessage(e),
            onRetry: () => ref.invalidate(ordersProvider),
          ),
          data: (orders) {
            if (orders.isEmpty) {
              return const _ErrorOrEmpty(
                icon: Icons.receipt_long_outlined,
                title: 'Belum ada pesanan',
                subtitle: 'Yuk mulai belanja produk favoritmu!',
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final order = orders[i];
                final status = order['status']?.toString() ?? 'pending';
                final grandTotal = (order['grand_total'] is int)
                    ? order['grand_total'] as int
                    : (order['grand_total'] as num?)?.toInt() ?? 0;
                final orderId = order['midtrans_order_id']?.toString() ?? order['id']?.toString() ?? '';
                final createdAt = order['created_at']?.toString() ?? '';
                final dateLabel = createdAt.isNotEmpty
                    ? createdAt.substring(0, createdAt.length > 10 ? 10 : createdAt.length)
                    : '';

                return _OrderCard(
                  orderId: orderId,
                  dateLabel: dateLabel,
                  status: status,
                  statusLabel: _statusLabel(status),
                  statusColor: _statusColor(status),
                  statusIcon: _statusIcon(status),
                  grandTotal: grandTotal,
                  fmtRp: _fmtRp,
                  onTap: () => context.push('/orders/${order['id']}'),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.orderId,
    required this.dateLabel,
    required this.status,
    required this.statusLabel,
    required this.statusColor,
    required this.statusIcon,
    required this.grandTotal,
    required this.fmtRp,
    required this.onTap,
  });
  final String orderId;
  final String dateLabel;
  final String status;
  final String statusLabel;
  final Color statusColor;
  final IconData statusIcon;
  final int grandTotal;
  final String Function(int) fmtRp;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: RimiColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), shape: BoxShape.circle),
                    child: Icon(statusIcon, color: statusColor, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(orderId, style: RimiTypography.labelMedium.copyWith(fontWeight: FontWeight.w700, fontSize: 13)),
                        if (dateLabel.isNotEmpty)
                          Text(dateLabel, style: RimiTypography.bodySmall.copyWith(fontSize: 11)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(statusLabel,
                        style: RimiTypography.labelSmall.copyWith(color: statusColor, fontWeight: FontWeight.w700, fontSize: 11)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: RimiTypography.bodySmall.copyWith(color: RimiColors.textSecondary)),
                  Text(fmtRp(grandTotal),
                      style: RimiTypography.titleMedium.copyWith(color: RimiColors.secondary, fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Spacer(),
                  Text('Lihat Detail', style: RimiTypography.labelMedium.copyWith(color: RimiColors.primary, fontWeight: FontWeight.w700)),
                  const Icon(Icons.chevron_right_rounded, color: RimiColors.primary, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorOrEmpty extends StatelessWidget {
  const _ErrorOrEmpty({required this.icon, required this.title, required this.subtitle, this.onRetry});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 120),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 72, color: RimiColors.neutralMuted),
                const SizedBox(height: 16),
                Text(title, style: RimiTypography.headlineSmall),
                const SizedBox(height: 4),
                Text(subtitle, style: RimiTypography.bodyMedium, textAlign: TextAlign.center),
                if (onRetry != null) ...[
                  const SizedBox(height: 16),
                  FilledButton(onPressed: onRetry, child: const Text('Coba lagi')),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
