import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/rimi_colors.dart';

class ShellPage extends ConsumerStatefulWidget {
  const ShellPage({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends ConsumerState<ShellPage> {
  int _index = 0;

  final _tabs = const [
    _Tab(icon: Icons.home_rounded, label: 'Beranda', route: '/home'),
    _Tab(icon: Icons.group_add_rounded, label: 'Ajak Teman', route: '/referral'),
    _Tab(icon: Icons.emoji_events_rounded, label: 'Poinku', route: '/rewards'),
    _Tab(icon: Icons.person_outlined, label: 'Profil', route: '/profile'),
  ];

  void _onTap(int i) {
    if (i == _index) return;
    setState(() => _index = i);
    context.go(_tabs[i].route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: RimiColors.navy.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_tabs.length, (i) {
                final t = _tabs[i];
                final active = i == _index;
                final color = active ? RimiColors.primary : RimiColors.navInactive;
                return Expanded(
                  child: InkWell(
                    onTap: () => _onTap(i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(t.icon, color: color, size: 24, fill: active ? 1.0 : 0.0),
                        const SizedBox(height: 4),
                        Text(
                          t.label,
                          style: GoogleFonts.quicksand(
                            fontSize: 12,
                            fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tab {
  const _Tab({required this.icon, required this.label, required this.route});
  final IconData icon;
  final String label;
  final String route;
}
