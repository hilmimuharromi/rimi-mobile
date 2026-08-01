import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_client.dart';
import '../../../core/theme/rimi_colors.dart';
import '../../../core/theme/rimi_typography.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  List _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final cart = await ref.read(apiClientProvider).getCart();
      setState(() {
        _items = (cart['items'] as List?) ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _updateQty(String id, int qty) async {
    if (qty < 1) return;
    try {
      await ref.read(apiClientProvider).updateCartItem(itemId: id, qty: qty);
      _load();
    } catch (_) {}
  }

  Future<void> _remove(String id) async {
    await ref.read(apiClientProvider).removeFromCart(id);
    _load();
  }

  int get _total {
    var t = 0;
    for (final item in _items) {
      final m = item as Map;
      final price = (m['price'] ?? 0) as int;
      final qty = (m['qty'] ?? 1) as int;
      t += price * qty;
    }
    return t;
  }

  String _formatRp(int amount) =>
      'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

  @override
  Widget build(BuildContext context) {
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
            onPressed: () {},
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _EmptyOrError(icon: Icons.error_outline, title: 'Gagal memuat', subtitle: _error!, onRetry: _load)
              : Column(
                  children: [
                    // Progress: Cart -> Checkout
                    const _ProgressBar(currentStep: 1),
                    // Page title
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Keranjang Belanja', style: RimiTypography.headlineMedium.copyWith(fontWeight: FontWeight.w800)),
                      ),
                    ),
                    Expanded(
                      child: _items.isEmpty
                          ? const _EmptyOrError(
                              icon: Icons.shopping_cart_outlined,
                              title: 'Keranjang kosong',
                              subtitle: 'Yuk mulai belanja produk favoritmu!',
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                              itemCount: _items.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, i) {
                                final item = _items[i] as Map;
                                return _CartItemCard(
                                  data: item,
                                  formatRp: _formatRp,
                                  onQtyChange: (q) => _updateQty(item['id'].toString(), q),
                                  onRemove: () => _remove(item['id'].toString()),
                                );
                              },
                            ),
                    ),
                  ],
                ),
      bottomNavigationBar: _items.isEmpty
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
                          Text('Total Belanja', style: RimiTypography.bodySmall.copyWith(color: RimiColors.textSecondary)),
                          const SizedBox(height: 2),
                          Text(
                            _formatRp(_total),
                            style: RimiTypography.headlineMedium.copyWith(color: RimiColors.secondary, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                    FilledButton(
                      onPressed: () => context.push('/checkout'),
                      style: FilledButton.styleFrom(
                        backgroundColor: RimiColors.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      child: Text('Check Out', style: RimiTypography.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.currentStep});
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          _Step(number: 1, label: 'Cart', active: currentStep >= 1),
          Expanded(child: Container(height: 1.5, color: currentStep >= 2 ? RimiColors.primaryDeep : RimiColors.border)),
          _Step(number: 2, label: 'Checkout', active: currentStep >= 2),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.label, required this.active});
  final int number;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: active ? RimiColors.primaryDeep : Colors.white,
            border: Border.all(color: active ? RimiColors.primaryDeep : RimiColors.border, width: 1.5),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: TextStyle(
              color: active ? Colors.white : RimiColors.neutralMuted,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: RimiTypography.labelSmall.copyWith(fontSize: 11, color: active ? RimiColors.textPrimary : RimiColors.textMuted)),
      ],
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.data,
    required this.formatRp,
    required this.onQtyChange,
    required this.onRemove,
  });
  final Map data;
  final String Function(int) formatRp;
  final ValueChanged<int> onQtyChange;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final name = data['product_name']?.toString() ?? data['name']?.toString() ?? 'Produk';
    final price = (data['price'] ?? 0) as int;
    final qty = (data['qty'] ?? 1) as int;
    final image = data['image_url']?.toString() ?? '';
    final desc = data['description']?.toString() ?? 'Hypoallergenic';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCFE7F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 72, height: 72,
              color: RimiColors.surface,
              child: image.isNotEmpty
                  ? Image.network(image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image_outlined, color: RimiColors.neutralMuted))
                  : const Icon(Icons.image_outlined, color: RimiColors.neutralMuted),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(name, maxLines: 2, overflow: TextOverflow.ellipsis,
                          style: RimiTypography.titleSmall.copyWith(fontWeight: FontWeight.w700)),
                    ),
                    GestureDetector(
                      onTap: onRemove,
                      child: const Icon(Icons.delete_outline_rounded, size: 20, color: RimiColors.neutralMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(desc, style: RimiTypography.bodySmall.copyWith(fontSize: 11)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        formatRp(price),
                        style: RimiTypography.titleMedium.copyWith(color: RimiColors.secondary, fontWeight: FontWeight.w700),
                      ),
                    ),
                    _QtyPill(qty: qty, onChange: onQtyChange),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyPill extends StatelessWidget {
  const _QtyPill({required this.qty, required this.onChange});
  final int qty;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: RimiColors.border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MiniBtn(icon: Icons.remove, onTap: qty > 1 ? () => onChange(qty - 1) : null),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text('$qty', style: RimiTypography.labelMedium.copyWith(fontWeight: FontWeight.w700)),
          ),
          _MiniBtn(icon: Icons.add, onTap: () => onChange(qty + 1)),
        ],
      ),
    );
  }
}

class _MiniBtn extends StatelessWidget {
  const _MiniBtn({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 22, height: 22,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: Icon(icon, size: 14, color: onTap == null ? RimiColors.border : RimiColors.neutral),
      ),
    );
  }
}

class _EmptyOrError extends StatelessWidget {
  const _EmptyOrError({required this.icon, required this.title, required this.subtitle, this.onRetry});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
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
    );
  }
}
