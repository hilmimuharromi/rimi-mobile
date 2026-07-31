import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_client.dart';
import '../../../core/theme/rimi_colors.dart';
import '../../../core/theme/rimi_typography.dart';
import '../../auth/providers/auth_provider.dart';

class RewardsPage extends ConsumerWidget {
  const RewardsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final points = 0;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: RimiColors.background,
        appBar: AppBar(
          title: const Text('Poinku & Rewards'),
        ),
        body: Column(
          children: [
            // Points card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [RimiColors.tertiary, Color(0xFFFFD97A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: RimiColors.tertiaryDark.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 44)),
                  const SizedBox(height: 8),
                  Text(
                    '$points',
                    style: RimiTypography.displayLarge.copyWith(
                      color: RimiColors.black,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Poin Saya',
                    style: RimiTypography.bodyMedium.copyWith(
                      color: RimiColors.black.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            // Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: RimiColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const TabBar(
                labelColor: RimiColors.primaryDeep,
                unselectedLabelColor: RimiColors.neutralMuted,
                indicatorColor: RimiColors.primaryDeep,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                tabs: [
                  Tab(text: 'Katalog Hadiah'),
                  Tab(text: 'Riwayat Tukar'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _CatalogTab(),
                  _HistoryTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CatalogTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final api = ref.watch(apiClientProvider);
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _loadCatalog(api),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.card_giftcard_rounded, size: 64, color: RimiColors.neutralMuted),
                const SizedBox(height: 16),
                Text('Belum ada reward', style: RimiTypography.titleMedium),
                Text('Kumpulkan poin dulu ya!', style: RimiTypography.bodyMedium),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) => _RewardTile(data: items[i]),
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _loadCatalog(ApiClient api) async {
    try {
      final result = await api.getRedemptionCatalog();
      if (result is List) return result.cast<Map<String, dynamic>>();
      if (result is Map) return (result['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      return [];
    } catch (_) {
      return [];
    }
  }
}

class _HistoryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.history_rounded, size: 64, color: RimiColors.neutralMuted),
          const SizedBox(height: 16),
          Text('Belum ada riwayat', style: RimiTypography.titleMedium),
        ],
      ),
    );
  }
}

class _RewardTile extends StatelessWidget {
  const _RewardTile({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RimiColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: RimiColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: RimiColors.tertiary.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.emoji_events_rounded, color: RimiColors.tertiaryDark),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['name']?.toString() ?? '', style: RimiTypography.titleSmall),
                const SizedBox(height: 4),
                Text(
                  '${data['points_cost'] ?? '?'} poin',
                  style: RimiTypography.bodySmall.copyWith(
                    color: RimiColors.primaryDeep,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              backgroundColor: RimiColors.primaryDeep,
              minimumSize: const Size(72, 40),
              textStyle: RimiTypography.labelMedium,
            ),
            child: const Text('Tukar'),
          ),
        ],
      ),
    );
  }
}
