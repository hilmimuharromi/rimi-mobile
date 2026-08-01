import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/rimi_colors.dart';
import '../../../core/theme/rimi_typography.dart';
import '../../../shared/widgets/rimi_mark.dart';
import '../../auth/providers/auth_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(authProvider.notifier).logout();
    if (context.mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final name = user?.displayName ?? 'Bunda Kirana';
    // fake card number derived from user id
    final card = _fakeCardNumber(user?.id ?? 'xxxx');

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Icon(Icons.menu_rounded, color: RimiColors.neutral),
        ),
        title: const RimiLogoLockup(markSize: 24, fontSize: 18),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: RimiColors.neutral),
            onPressed: () {},
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined, color: RimiColors.neutral),
                onPressed: () => context.push('/cart'),
              ),
              Positioned(
                top: 8, right: 6,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(color: RimiColors.error, shape: BoxShape.circle),
                  child: const Text('2',
                      style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ---- Member Card ----
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF28B6D), Color(0xFFF9B44E)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: RimiColors.secondary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('RIMI MEMBER CARD',
                                style: RimiTypography.labelMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                    fontSize: 12)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 12),
                                  const SizedBox(width: 3),
                                  Text('Gold Tier',
                                      style: RimiTypography.labelSmall
                                          .copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 10)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(name,
                            style: RimiTypography.bodyMedium
                                .copyWith(color: Colors.white, fontSize: 13)),
                        const SizedBox(height: 40),
                        Text(card,
                            style: RimiTypography.titleMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                                fontSize: 16)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              width: 28, height: 20,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0D080),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('Valid thru 12/26',
                                style: RimiTypography.labelSmall
                                    .copyWith(color: Colors.white, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Si Rimi cloud in blue box
                  Container(
                    width: 78, height: 78,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFA8D8EA),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Container(
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: const Text('☁', style: TextStyle(fontSize: 26)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ---- Order Status Shortcuts ----
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: const Row(
              children: [
                Expanded(child: _OrderShortcut(icon: Icons.receipt_long_outlined, label: 'Perlu\nBayar')),
                Expanded(child: _OrderShortcut(icon: Icons.inventory_2_outlined, label: 'Dikemas')),
                Expanded(child: _OrderShortcut(icon: Icons.local_shipping_outlined, label: 'Dikirim')),
                Expanded(child: _OrderShortcut(icon: Icons.star_border_rounded, label: 'Beri Nilai')),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ---- Menu ----
          Container(
            color: Colors.white,
            child: Column(
              children: [
                _MenuTile(icon: Icons.history_rounded, label: 'Riwayat Pesanan', onTap: () => context.push('/orders')),
                _Divider(),
                _MenuTile(icon: Icons.location_on_outlined, label: 'Daftar Alamat', onTap: () {}),
                _Divider(),
                _MenuTile(icon: Icons.favorite_border_rounded, label: 'Produk Favorit', onTap: () {}),
                _Divider(),
                _MenuTile(icon: Icons.help_outline_rounded, label: 'Pusat Bantuan', onTap: () {}),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ---- Logout ----
          Center(
            child: TextButton(
              onPressed: () => _logout(context, ref),
              child: Text('Keluar Akun',
                  style: RimiTypography.labelLarge
                      .copyWith(color: RimiColors.secondary, fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _fakeCardNumber(String seed) {
    final h = seed.hashCode.abs().toString().padLeft(16, '0').substring(0, 16);
    return '${h.substring(0, 4)} ${h.substring(4, 8)} ${h.substring(8, 12)} ${h.substring(12, 16)}';
  }
}

class _OrderShortcut extends StatelessWidget {
  const _OrderShortcut({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48, height: 48,
          decoration: const BoxDecoration(color: Color(0xFFEBF4FA), shape: BoxShape.circle),
          child: Icon(icon, color: RimiColors.secondary, size: 24),
        ),
        const SizedBox(height: 6),
        Text(label,
            textAlign: TextAlign.center,
            style: RimiTypography.labelSmall
                .copyWith(color: RimiColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: const BoxDecoration(color: Color(0xFFEBF4FA), shape: BoxShape.circle),
              child: Icon(icon, color: RimiColors.secondary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: RimiTypography.labelLarge.copyWith(fontWeight: FontWeight.w600, fontSize: 15)),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFCCCCCC)),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE), indent: 20, endIndent: 20);
}
