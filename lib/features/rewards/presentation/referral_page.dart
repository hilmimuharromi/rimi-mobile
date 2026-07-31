import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/rimi_colors.dart';
import '../../../core/theme/rimi_typography.dart';
import '../../../shared/models/user.dart';
import '../../auth/providers/auth_provider.dart';

class ReferralPage extends ConsumerWidget {
  const ReferralPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final code = auth.user?.referralCode ?? '—';

    return Scaffold(
      backgroundColor: RimiColors.background,
      appBar: AppBar(title: const Text('Ajak Teman')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [RimiColors.secondary, RimiColors.secondaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Text('🤝', style: TextStyle(fontSize: 52)),
                  const SizedBox(height: 12),
                  Text(
                    'Dapat 5.000 poin',
                    style: RimiTypography.headlineLarge.copyWith(color: RimiColors.white),
                  ),
                  Text(
                    'untuk tiap teman yang belanja',
                    style: RimiTypography.bodyMedium.copyWith(
                      color: RimiColors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text('Kode Referral Kamu', style: RimiTypography.titleMedium),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: RimiColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: RimiColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      code,
                      style: RimiTypography.headlineLarge.copyWith(
                        color: RimiColors.primaryDeep,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('📋 Kode disalin')),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, color: RimiColors.primaryDeep),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Cara kerja', style: RimiTypography.titleMedium),
            const SizedBox(height: 12),
            _Step(icon: Icons.share_rounded, title: 'Bagikan kode referral', subtitle: 'Kirim ke teman via WhatsApp / chat'),
            const SizedBox(height: 8),
            _Step(icon: Icons.person_add_rounded, title: 'Teman daftar & belanja', subtitle: 'Teman mendaftar pakai kode kamu'),
            const SizedBox(height: 8),
            _Step(icon: Icons.emoji_events_rounded, title: 'Dapat 5.000 poin', subtitle: 'Poin masuk otomatis tiap transaksi'),
            const SizedBox(height: 24),
            Text('Daftar downline', style: RimiTypography.titleMedium),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: RimiColors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  'Belum ada downline',
                  style: RimiTypography.bodyMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: RimiColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: RimiColors.primaryDeep, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: RimiTypography.titleSmall),
              const SizedBox(height: 2),
              Text(subtitle, style: RimiTypography.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
