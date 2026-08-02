import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/theme/rimi_colors.dart';
import '../../../core/theme/rimi_typography.dart';
import '../../../shared/widgets/rimi_mark.dart';

/// Fetches order detail (items + order meta) from BE `/api/v1/orders/:id`.
final orderDetailProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, id) async {
  final api = ref.watch(apiClientProvider);
  return api.getOrder(id);
});

class OrderDetailPage extends ConsumerWidget {
  const OrderDetailPage({super.key, required this.orderId});
  final String orderId;

  String _fmtRp(int amount) =>
      'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\\d{1,3})(?=(\\d{3})+(?!\\d))'), (m) => '${m[1]}.')}';

  Color _statusColor(String status) {
    switch (status) {
      case 'completed': return RimiColors.success;
      case 'pending': return RimiColors.warning;
      case 'cancelled': case 'failed': return RimiColors.error;
      case 'paid': case 'processing': case 'shipped': return RimiColors.info;
      default: return RimiColors.neutralSoft;
    }
  }

  String _statusLabel(String status) {
    const labels = {
      'pending': 'Menunggu Bayar', 'paid': 'Dibayar', 'processing': 'Diproses',
      'shipped': 'Dikirim', 'completed': 'Selesai', 'cancelled': 'Dibatalkan', 'failed': 'Gagal',
    };
    return labels[status] ?? status;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(orderDetailProvider(orderId));

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
        title: const Text('Detail Pesanan', style: TextStyle(color: RimiColors.neutral, fontWeight: FontWeight.w700)),
        centerTitle: false,
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _Center(icon: Icons.error_outline, title: 'Gagal memuat', subtitle: apiErrorMessage(e)),
        data: (data) {
          final order = (data['order'] as Map<String, dynamic>?) ?? data;
          final items = (data['items'] as List?) ?? [];

          final status = order['status']?.toString() ?? 'pending';
          final orderIdStr = order['midtrans_order_id']?.toString() ?? order['id']?.toString() ?? '';
          final total = (order['total'] is int) ? order['total'] as int : (order['total'] as num?)?.toInt() ?? 0;
          final shippingCost = (order['shipping_cost'] is int) ? order['shipping_cost'] as int : (order['shipping_cost'] as num?)?.toInt() ?? 0;
          final grandTotal = (order['grand_total'] is int) ? order['grand_total'] as int : (order['grand_total'] as num?)?.toInt() ?? 0;
          final shippingMethod = order['shipping_method']?.toString() ?? '-';
          final createdAt = order['created_at']?.toString() ?? '';
          final paidAt = order['paid_at']?.toString() ?? '';
          final statusColor = _statusColor(status);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            children: [
              // Status banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                      child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_statusLabel(status), style: RimiTypography.titleMedium.copyWith(color: statusColor, fontWeight: FontWeight.w800)),
                          Text(orderIdStr, style: RimiTypography.bodySmall.copyWith(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Items list
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: RimiColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                      child: Text('Produk Dipesan (${items.length})', style: RimiTypography.titleSmall.copyWith(fontWeight: FontWeight.w700)),
                    ),
                    ...items.map((raw) {
                      final item = raw as Map<String, dynamic>;
                      final qty = (item['qty'] is int) ? item['qty'] as int : (item['qty'] as num?)?.toInt() ?? 1;
                      final price = (item['price_snapshot'] is int) ? item['price_snapshot'] as int : (item['price_snapshot'] as num?)?.toInt() ?? 0;
                      final cashback = (item['cashback_percentage_snapshot'] as num?)?.toDouble() ?? 0;
                      return _OrderItemTile(qty: qty, price: price, cashback: cashback, fmtRp: _fmtRp);
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Shipping info
              _InfoCard(
                title: 'Info Pengiriman',
                icon: Icons.local_shipping_outlined,
                rows: [
                  {'label': 'Metode', 'value': shippingMethod.toUpperCase()},
                  {'label': 'Ongkos Kirim', 'value': _fmtRp(shippingCost)},
                ],
              ),
              const SizedBox(height: 12),

              // Payment summary
              _InfoCard(
                title: 'Rincian Pembayaran',
                icon: Icons.receipt_long_outlined,
                rows: [
                  {'label': 'Subtotal Produk', 'value': _fmtRp(total)},
                  {'label': 'Ongkos Kirim', 'value': _fmtRp(shippingCost)},
                  {'label': 'Total Bayar', 'value': _fmtRp(grandTotal), 'bold': true},
                ],
              ),
              const SizedBox(height: 12),

              // Timeline
              _InfoCard(
                title: 'Waktu',
                icon: Icons.schedule_outlined,
                rows: [
                  {'label': 'Dibuat', 'value': _formatDate(createdAt)},
                  if (paidAt.isNotEmpty) {'label': 'Dibayar', 'value': _formatDate(paidAt)},
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(String iso) {
    if (iso.isEmpty) return '-';
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso.length > 16 ? iso.substring(0, 16) : iso;
    }
  }
}

class _OrderItemTile extends StatelessWidget {
  const _OrderItemTile({required this.qty, required this.price, required this.cashback, required this.fmtRp});
  final int qty;
  final int price;
  final double cashback;
  final String Function(int) fmtRp;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(color: RimiColors.surface, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.inventory_2_outlined, size: 24, color: RimiColors.neutralMuted),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Produk', style: RimiTypography.bodyMedium.copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text('${fmtRp(price)} x $qty', style: RimiTypography.bodySmall.copyWith(fontSize: 12)),
                    if (cashback > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(color: RimiColors.successSoft, borderRadius: BorderRadius.circular(4)),
                        child: Text('Cashback ${cashback}%', style: RimiTypography.labelSmall.copyWith(fontSize: 10, color: RimiColors.success)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Text(fmtRp(price * qty), style: RimiTypography.titleSmall.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.icon, required this.rows});
  final String title;
  final IconData icon;
  final List<Map<String, dynamic>> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: RimiColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: RimiColors.secondary),
              const SizedBox(width: 8),
              Text(title, style: RimiTypography.titleSmall.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          ...rows.map((r) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(r['label']?.toString() ?? '', style: r['bold'] == true
                    ? RimiTypography.titleSmall.copyWith(fontWeight: FontWeight.w700)
                    : RimiTypography.bodyMedium.copyWith(fontSize: 13)),
                Text(r['value']?.toString() ?? '', style: r['bold'] == true
                    ? RimiTypography.titleMedium.copyWith(color: RimiColors.secondary, fontWeight: FontWeight.w800)
                    : RimiTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _Center extends StatelessWidget {
  const _Center({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: RimiColors.neutralMuted),
            const SizedBox(height: 12),
            Text(title, style: RimiTypography.headlineSmall),
            const SizedBox(height: 4),
            Text(subtitle, style: RimiTypography.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
