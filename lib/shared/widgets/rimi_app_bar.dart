import 'package:flutter/material.dart';
import '../../core/theme/rimi_colors.dart';
import '../../core/theme/rimi_typography.dart';

class RimiAppBar extends StatelessWidget implements PreferredSizeWidget {
  const RimiAppBar({super.key, required this.title, this.actions});

  final String title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: RimiColors.white,
      foregroundColor: RimiColors.textPrimary,
      elevation: 0,
      shadowColor: RimiColors.border.withValues(alpha: 0.3),
      surfaceTintColor: Colors.transparent,
      title: Text(title, style: RimiTypography.titleLarge),
      actions: actions,
    );
  }
}
