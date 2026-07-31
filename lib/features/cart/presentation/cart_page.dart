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
  Map<String, dynamic>? _cart;
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
        _cart = cart;
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: RimiColors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shopping_cart_outlined, size: 64, color: RimiColors.neutralMuted),
              const SizedBox(height: 16),
              Text('Gagal memuat keranjang', style: RimiTypography.titleMedium),
              const SizedBox(height: 8),
              Text(_error!, style: RimiTypography.bodySmall, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _load,
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: RimiColors.background,
      appBar: AppBar(
        title: const Text('Keranjang'),
        actions: [
          IconButton(
            icon: const Icon(Icons.badge_outlined),
            onPressed: () => context.push('/profile/member'),
            tooltip: 'Member Card',
          ),
        ],
      ),
      body: Column(
        children: [
          // Points info bar
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: RimiColors.tertiary.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: RimiColors.tertiary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_events_rounded, color: RimiColors.tertiaryDark, size: 20),
                const SizedBox(width: 8),
                Text('Belanja sekarang dapat poin!', style: RimiTypography.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.shopping_cart_outlined, size: 80, color: RimiColors.neutralMuted),
                        const SizedBox(height: 16),
                        Text('Keranjang kosong', style: RimiTypography.headlineSmall),
                        const SizedBox(height: 8),
                        Text(
                          'Yuk mulai belanja!',
                          style: RimiTypography.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => context.go('/home'),
                          child: const Text('Jelajahi Produk'),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final item = _items[i];
                      return _CartItemTile(
                        data: item,
                        onRemove: () async {
                          await ref.read(apiClientProvider).removeFromCart(item['id'].toString());
                          _load();
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _items.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: RimiColors.white,
                boxShadow: [
                  BoxShadow(
                    color: RimiColors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: () => context.push('/checkout'),
                  child: const Text('Checkout Sekarang'),
                ),
              ),
            )
          : null,
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({required this.data, this.onRemove});
  final dynamic data;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final product = (data['product'] as Map<String, dynamic>?) ?? {};
    final name = product['name']?.toString() ?? 'Produk';
    final price = product['price'] ?? 0;
    final qty = data['qty'] ?? 1;
    final image = product['image']?.toString() ?? product['images']?.first ?? '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: RimiColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: RimiColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 72,
              height: 72,
              color: RimiColors.surface,
              child: image.isNotEmpty
                  ? Image.network(image, fit: BoxFit.cover)
                  : const Icon(Icons.image_not_supported, color: RimiColors.neutralMuted),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, style: RimiTypography.bodyMedium),
                const SizedBox(height: 4),
                Text('Rp $price x$qty', style: RimiTypography.bodySmall),
                Text(
                  'Rp ${price * qty}',
                  style: RimiTypography.titleMedium.copyWith(color: RimiColors.primaryDeep),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.remove_circle_outline_rounded),
            color: RimiColors.error,
          ),
        ],
      ),
    );
  }
}
