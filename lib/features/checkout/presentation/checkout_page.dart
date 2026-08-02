import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_client.dart';
import '../../../core/theme/rimi_colors.dart';
import '../../../core/theme/rimi_typography.dart';
import '../../../shared/widgets/rimi_mark.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  List _cartItems = [];
  List<Map<String, dynamic>> _addresses = [];
  Map<String, dynamic>? _selectedAddress;
  String _shippingMethod = 'regular';
  bool _loading = true;
  bool _placing = false;
  String? _error;

  final _shippingOptions = const [
    {'key': 'regular', 'label': 'Reguler (2-3 hari)', 'cost': 12000},
    {'key': 'express', 'label': 'Express (1 hari)', 'cost': 25000},
    {'key': 'sameday', 'label': 'Same Day', 'cost': 35000},
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final api = ref.read(apiClientProvider);
      final cart = await api.getCart();
      final addresses = await api.listAddresses();
      setState(() {
        _cartItems = (cart['items'] as List?) ?? [];
        _addresses = addresses;
        _selectedAddress = addresses.isNotEmpty ? addresses.first : null;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  int get _subtotal {
    var t = 0;
    for (final item in _cartItems) {
      final m = item as Map;
      final price = (m['price'] is int) ? m['price'] as int : (m['price'] as num?)?.toInt() ?? 0;
      final qty = (m['qty'] is int) ? m['qty'] as int : (m['qty'] as num?)?.toInt() ?? 1;
      t += price * qty;
    }
    return t;
  }

  int get _shippingCost {
    return _shippingOptions.firstWhere((o) => o['key'] == _shippingMethod)['cost'] as int;
  }

  int get _grandTotal => _subtotal + _shippingCost;

  String _fmtRp(int amount) =>
      'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\\d{1,3})(?=(\\d{3})+(?!\\d))'), (m) => '${m[1]}.')}';

  Future<void> _placeOrder() async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih alamat pengiriman dulu')),
      );
      return;
    }
    setState(() => _placing = true);
    try {
      final api = ref.read(apiClientProvider);
      final result = await api.createOrder(
        addressId: _selectedAddress!['id'].toString(),
        shippingOption: _shippingMethod,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pesanan berhasil dibuat!')),
        );
        context.go('/orders');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: ${apiErrorMessage(e)}')),
        );
      }
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: const RimiLogoLockup(markSize: 24, fontSize: 18),
        centerTitle: false,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorBody(error: _error!, onRetry: _load)
              : _cartItems.isEmpty
                  ? const _EmptyState(icon: Icons.shopping_cart_outlined, title: 'Keranjang kosong', subtitle: 'Tambahkan produk dulu')
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                      children: [
                        // Step indicator
                        const _StepIndicator(current: 2, steps: ['Keranjang', 'Checkout', 'Selesai']),
                        const SizedBox(height: 16),

                        // Address section
                        _SectionCard(
                          title: 'Alamat Pengiriman',
                          icon: Icons.location_on_outlined,
                          child: _selectedAddress == null
                              ? Text('Belum ada alamat. Tambahkan di menu Alamat.', style: RimiTypography.bodyMedium)
                              : _AddressTile(
                                  data: _selectedAddress!,
                                  selected: true,
                                  onTap: () => context.push('/addresses'),
                                ),
                        ),
                        if (_addresses.length > 1)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => context.push('/addresses'),
                                child: Text('Ganti alamat', style: RimiTypography.labelMedium.copyWith(color: RimiColors.secondary)),
                              ),
                            ),
                          ),

                        const SizedBox(height: 12),

                        // Cart items summary
                        _SectionCard(
                          title: 'Ringkasan Pesanan (${_cartItems.length} item)',
                          icon: Icons.shopping_bag_outlined,
                          child: Column(
                            children: _cartItems.map((item) {
                              final m = item as Map;
                              final name = m['product_name']?.toString() ?? m['name']?.toString() ?? 'Produk';
                              final price = (m['price'] is int) ? m['price'] as int : (m['price'] as num?)?.toInt() ?? 0;
                              final qty = (m['qty'] is int) ? m['qty'] as int : (m['qty'] as num?)?.toInt() ?? 1;
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40, height: 40,
                                      decoration: BoxDecoration(color: RimiColors.surface, borderRadius: BorderRadius.circular(8)),
                                      child: const Icon(Icons.inventory_2_outlined, size: 20, color: RimiColors.neutralMuted),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(child: Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, style: RimiTypography.bodyMedium.copyWith(fontSize: 13))),
                                    Text('x$qty', style: RimiTypography.labelMedium.copyWith(color: RimiColors.textSecondary)),
                                    const SizedBox(width: 8),
                                    Text(_fmtRp(price * qty), style: RimiTypography.labelMedium.copyWith(fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Shipping options
                        _SectionCard(
                          title: 'Pilih Pengiriman',
                          icon: Icons.local_shipping_outlined,
                          child: Column(
                            children: _shippingOptions.map((opt) {
                              final selected = opt['key'] == _shippingMethod;
                              return RadioListTile<String>(
                                value: opt['key'] as String,
                                groupValue: _shippingMethod,
                                onChanged: (v) => setState(() => _shippingMethod = v!),
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: Text(opt['label'] as String, style: RimiTypography.bodyMedium.copyWith(fontSize: 14)),
                                subtitle: Text(_fmtRp(opt['cost'] as int), style: RimiTypography.labelSmall.copyWith(color: RimiColors.secondary)),
                                activeColor: RimiColors.secondary,
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Payment summary
                        _SectionCard(
                          title: 'Rincian Pembayaran',
                          icon: Icons.receipt_long_outlined,
                          child: Column(
                            children: [
                              _PaymentRow(label: 'Subtotal Produk', value: _fmtRp(_subtotal)),
                              const SizedBox(height: 6),
                              _PaymentRow(label: 'Ongkos Kirim', value: _fmtRp(_shippingCost)),
                              const Divider(height: 16),
                              _PaymentRow(
                                label: 'Total Bayar',
                                value: _fmtRp(_grandTotal),
                                bold: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
      bottomNavigationBar: _loading || _cartItems.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: RimiColors.border)),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total', style: RimiTypography.bodySmall.copyWith(color: RimiColors.textSecondary)),
                          Text(_fmtRp(_grandTotal),
                              style: RimiTypography.headlineMedium.copyWith(color: RimiColors.secondary, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                    FilledButton(
                      onPressed: _placing ? null : _placeOrder,
                      style: FilledButton.styleFrom(
                        backgroundColor: RimiColors.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _placing
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Buat Pesanan', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

// ─── Widgets ───

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current, required this.steps});
  final int current;
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final stepIdx = i ~/ 2;
          return Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              color: stepIdx < current - 1 ? RimiColors.secondary : RimiColors.border,
            ),
          );
        }
        final stepIdx = i ~/ 2;
        final done = stepIdx < current - 1;
        final active = stepIdx == current - 1;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                color: done || active ? RimiColors.secondary : RimiColors.border,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: done
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : Text('${stepIdx + 1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: 6),
            Text(steps[stepIdx],
                style: RimiTypography.labelSmall.copyWith(
                  color: active ? RimiColors.neutral : RimiColors.textMuted,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                )),
          ],
        );
      }),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.icon, required this.child});
  final String title;
  final IconData icon;
  final Widget child;

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
          child,
        ],
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  const _AddressTile({required this.data, this.selected = false, this.onTap});
  final Map<String, dynamic> data;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final name = data['recipient_name']?.toString() ?? '';
    final phone = data['phone']?.toString() ?? '';
    final detail = data['detail']?.toString() ?? '';
    final city = data['city']?.toString() ?? '';
    final label = data['label']?.toString() ?? '';
    final isDefault = data['is_default'] == true;

    return InkWell(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name, style: RimiTypography.titleSmall.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    if (label.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: RimiColors.cloud, borderRadius: BorderRadius.circular(6)),
                        child: Text(label, style: RimiTypography.labelSmall.copyWith(fontSize: 10, color: RimiColors.primary)),
                      ),
                    if (isDefault) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: RimiColors.coralSoft, borderRadius: BorderRadius.circular(6)),
                        child: Text('Utama', style: RimiTypography.labelSmall.copyWith(fontSize: 10, color: RimiColors.secondary)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(phone, style: RimiTypography.bodySmall),
                const SizedBox(height: 2),
                Text('$detail${city.isNotEmpty ? ', $city' : ''}', style: RimiTypography.bodySmall.copyWith(fontSize: 12)),
              ],
            ),
          ),
          if (selected)
            const Icon(Icons.check_circle, color: RimiColors.secondary, size: 20),
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.label, required this.value, this.bold = false});
  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: bold
            ? RimiTypography.titleSmall.copyWith(fontWeight: FontWeight.w700)
            : RimiTypography.bodyMedium.copyWith(fontSize: 13)),
        Text(value, style: bold
            ? RimiTypography.titleMedium.copyWith(color: RimiColors.secondary, fontWeight: FontWeight.w800)
            : RimiTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.error, required this.onRetry});
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: RimiColors.neutralMuted),
            const SizedBox(height: 12),
            Text('Gagal memuat', style: RimiTypography.headlineSmall),
            const SizedBox(height: 4),
            Text(error, style: RimiTypography.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Coba lagi')),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.title, required this.subtitle});
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
            Icon(icon, size: 72, color: RimiColors.neutralMuted),
            const SizedBox(height: 12),
            Text(title, style: RimiTypography.headlineSmall),
            const SizedBox(height: 4),
            Text(subtitle, style: RimiTypography.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
