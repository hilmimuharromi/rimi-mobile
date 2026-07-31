import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/api/api_client.dart';
import '../../../core/theme/rimi_colors.dart';
import '../../../core/theme/rimi_typography.dart';
import '../../../shared/models/user.dart';
import '../../../shared/widgets/rimi_app_bar.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  String? _cachedName;

  @override
  void initState() {
    super.initState();
    _loadCachedName();
  }

  Future<void> _loadCachedName() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('user_name');
    if (cached != null) setState(() => _cachedName = cached);
  }

  Future<void> _logout() async {
    await ref.read(authProvider.notifier).logout();
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final user = auth.user;

    return Scaffold(
      backgroundColor: RimiColors.background,
      appBar: const RimiAppBar(title: 'Profil'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: RimiColors.primary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: RimiColors.primary, width: 4),
              ),
              child: const Icon(Icons.child_care_rounded, size: 52, color: RimiColors.primaryDeep),
            ),
            const SizedBox(height: 16),
            Text(
              user?.displayName ?? _cachedName ?? 'Member Rimi',
              style: RimiTypography.headlineMedium,
              textAlign: TextAlign.center,
            ),
            Text(
              user?.phone ?? user?.email ?? 'member@rimi.id',
              style: RimiTypography.bodySmall,
            ),
            const SizedBox(height: 24),
            _ProfileSection(
              title: 'Poinku',
              value: '0',
              subtitle: 'Poin saat ini',
              icon: Icons.emoji_events_rounded,
              onTap: () => context.push('/rewards'),
            ),
            const SizedBox(height: 12),
            _ProfileSection(
              title: 'Referral',
              value: '0',
              subtitle: 'Undangan aktif',
              icon: Icons.group_add_rounded,
              onTap: () => context.push('/profile/referral'),
            ),
            const SizedBox(height: 12),
            _ProfileSection(
              title: 'Alamat',
              value: '2',
              subtitle: 'Rumah & kantor',
              icon: Icons.location_on_rounded,
              onTap: () => context.push('/profile/address'),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: RimiColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _ProfileTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Profil & Member Card',
                    onTap: () => context.push('/profile/member'),
                  ),
                  const Divider(height: 1, thickness: 1),
                  _ProfileTile(
                    icon: Icons.card_giftcard_outlined,
                    title: 'Poinku & Rewards',
                    onTap: () => context.push('/rewards'),
                  ),
                  const Divider(height: 1, thickness: 1),
                  _ProfileTile(
                    icon: Icons.redeem_rounded,
                    title: 'Redeem Hadiah',
                    onTap: () => context.push('/rewards'),
                  ),
                  const Divider(height: 1, thickness: 1),
                  _ProfileTile(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Riwayat Pesanan',
                    onTap: () => context.push('/orders'),
                  ),
                  const Divider(height: 1, thickness: 1),
                  _ProfileTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifikasi',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: RimiColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _ProfileTile(
                    icon: Icons.settings_outlined,
                    title: 'Pengaturan',
                    onTap: () => context.push('/profile/settings'),
                  ),
                  const Divider(height: 1, thickness: 1),
                  _ProfileTile(
                    icon: Icons.support_agent_outlined,
                    title: 'Bantuan & FAQ',
                  ),
                  const Divider(height: 1, thickness: 1),
                  _ProfileTile(
                    icon: Icons.logout_rounded,
                    title: 'Keluar',
                    textColor: RimiColors.error,
                    onTap: _logout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: RimiColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: RimiColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: RimiColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: RimiColors.primaryDeep),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: RimiTypography.labelLarge),
                  const SizedBox(height: 2),
                  Text(value, style: RimiTypography.headlineMedium),
                  Text(subtitle, style: RimiTypography.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: RimiColors.neutralMuted),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.textColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 22, color: RimiColors.neutral),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: RimiTypography.bodyLarge.copyWith(color: textColor ?? RimiColors.textPrimary),
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: RimiTypography.bodySmall,
              ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: RimiColors.neutralMuted),
          ],
        ),
      ),
    );
  }
}
