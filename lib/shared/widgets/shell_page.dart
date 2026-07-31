import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/rimi_colors.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/cart/presentation/cart_page.dart';
import '../../features/rewards/presentation/rewards_page.dart';
import '../../features/profile/presentation/profile_page.dart';

class ShellPage extends ConsumerStatefulWidget {
  const ShellPage({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends ConsumerState<ShellPage> {
  int _index = 0;

  final _tabs = [
    const _Tab(icon: Icons.home_rounded, label: 'Beranda'),
    const _Tab(icon: Icons.category_outlined, label: 'Produk'),
    const _Tab(icon: Icons.shopping_bag_outlined, label: 'Keranjang'),
    const _Tab(icon: Icons.emoji_events_rounded, label: 'Rewards'),
    const _Tab(icon: Icons.person_outlined, label: 'Profil'),
  ];

  void _onTap(int i) {
    if (i == _index) return;
    setState(() => _index = i);
    switch (i) {
      case 0:
        context.go('/home');
      case 1:
        context.go('/home/products');
      case 2:
        context.go('/cart');
      case 3:
        context.go('/rewards');
      case 4:
        context.go('/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _onTap,
        backgroundColor: RimiColors.white,
        indicatorColor: RimiColors.primary.withValues(alpha: 0.25),
        elevation: 2,
        surfaceTintColor: Colors.transparent,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: _tabs.map((t) {
          return NavigationDestination(
            icon: Icon(t.icon, color: RimiColors.neutralMuted),
            selectedIcon: Icon(t.icon, color: RimiColors.primaryDeep),
            label: t.label,
          );
        }).toList(),
      ),
    );
  }
}

class _Tab {
  const _Tab({required this.icon, required this.label});
  final IconData icon;
  final String label;
}
