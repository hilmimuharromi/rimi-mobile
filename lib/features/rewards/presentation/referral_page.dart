import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/theme/rimi_colors.dart';
import '../../../core/theme/rimi_typography.dart';
import '../../auth/providers/auth_provider.dart';

/// Live downline list from BE `/api/v1/referral/downline`.
final referralDownlineProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final api = ref.watch(apiClientProvider);
  try {
    return await api.getReferralDownline(limit: 20);
  } catch (_) {
    return <Map<String, dynamic>>[];
  }
});

class ReferralPage extends ConsumerWidget {
  const ReferralPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final downlineAsync = ref.watch(referralDownlineProvider);
    final code = auth.user?.referralCode ?? 'RIMI-SAYANG-IBU';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Icon(Icons.menu_rounded, color: RimiColors.neutral),
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
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ---- Hero card ----
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFBFE3FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Untung Bareng Sahabat!',
                            style: RimiTypography.headlineMedium.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        Text(
                          'Ajak teman belanja, kalian berdua dapat cashback poin melimpah!',
                          style: RimiTypography.bodyMedium.copyWith(color: RimiColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Si Rimi cloud
                  Container(
                    width: 74, height: 74,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(top: 22, left: 22, child: _MiniDot()),
                        Positioned(top: 22, right: 22, child: _MiniDot()),
                        Positioned(top: 30, left: 18, child: _MiniCheek()),
                        Positioned(top: 30, right: 18, child: _MiniCheek()),
                        const Positioned(bottom: 14, child: Text('Si Rimi', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ---- Referral code section ----
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DottedBorder(
              color: RimiColors.border,
              radius: 16,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('KODE REFERRAL KAMU',
                        style: RimiTypography.labelSmall.copyWith(
                            color: RimiColors.primaryDeep, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: RimiColors.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              code,
                              style: RimiTypography.headlineMedium.copyWith(
                                  fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 1),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              await Clipboard.setData(ClipboardData(text: code));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('📋 Kode disalin')),
                              );
                            },
                            child: Row(
                              children: [
                                Icon(Icons.copy_rounded, size: 16, color: RimiColors.secondary),
                                const SizedBox(width: 4),
                                Text('Salin',
                                    style: RimiTypography.labelMedium
                                        .copyWith(color: RimiColors.secondary, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Bagikan kode ini dan dapatkan 10.000 Poin untuk tiap teman yang bergabung.',
                      style: RimiTypography.bodySmall.copyWith(color: RimiColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ---- Teman Terundang ----
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('Teman Terundang',
                    style: RimiTypography.titleLarge.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(width: 8),
                downlineAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (list) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: RimiColors.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('${list.length} Teman',
                        style: RimiTypography.labelSmall
                            .copyWith(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          downlineAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                  child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
            ),
            error: (_, __) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Gagal memuat teman', style: RimiTypography.bodySmall.copyWith(color: RimiColors.error)),
            ),
            data: (list) {
              if (list.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Belum ada teman yang bergabung',
                      style: RimiTypography.bodySmall, textAlign: TextAlign.center),
                );
              }
              return Column(children: list.map(_downlineTile).toList());
            },
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_circle_outline_rounded, size: 18, color: RimiColors.neutralMuted),
              label: Text('Ajak Lebih Banyak Lagi',
                  style: RimiTypography.labelMedium.copyWith(color: RimiColors.textSecondary)),
            ),
          ),

          const SizedBox(height: 16),
          // ---- Bottom promo card ----
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [RimiColors.secondary, RimiColors.secondaryDark],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kejar Bonus Poin\nAkhir Bulan!',
                            style: RimiTypography.headlineSmall
                                .copyWith(color: Colors.white, fontWeight: FontWeight.w800, height: 1.2)),
                        const SizedBox(height: 4),
                        Text('Hingga 50.000 Poin Tambahan',
                            style: RimiTypography.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.9))),
                      ],
                    ),
                  ),
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        child: Text('Lihat Detail',
                            style: RimiTypography.labelMedium
                                .copyWith(color: RimiColors.secondary, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _downlineTile(Map<String, dynamic> d) {
    final name = d['full_name']?.toString() ?? 'Member';
    final orderCount = (d['order_count'] as num?)?.toInt() ?? 0;
    final joined = d['joined_at']?.toString() ?? '';
    final active = orderCount > 0;
    return _FriendTile(
      name: name,
      subtitle: active ? 'Bergabung • $joined' : 'Menunggu transaksi pertama',
      points: active ? '+5.000 Pts' : '--',
      status: active ? 'Berhasil' : 'Proses',
      statusColor: active ? RimiColors.primary : const Color(0xFFFF9800),
    );
  }
}

class _FriendTile extends StatelessWidget {
  const _FriendTile({
    required this.name,
    required this.subtitle,
    required this.points,
    required this.status,
    required this.statusColor,
  });
  final String name;
  final String subtitle;
  final String points;
  final String status;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: const BoxDecoration(color: Color(0xFFEDF5FA), shape: BoxShape.circle),
            child: const Icon(Icons.person_outline_rounded, color: RimiColors.neutral, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: RimiTypography.labelLarge.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Flexible(
                      child: Text(subtitle,
                          style: RimiTypography.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    const Icon(Icons.chevron_right_rounded, size: 14, color: RimiColors.neutralMuted),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(points,
                  style: RimiTypography.labelLarge
                      .copyWith(fontWeight: FontWeight.w800, color: RimiColors.textPrimary)),
              const SizedBox(height: 2),
              Text(status,
                  style: RimiTypography.labelSmall.copyWith(color: statusColor, fontWeight: FontWeight.w700, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 4, height: 4,
        decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
      );
}

class _MiniCheek extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 6, height: 3,
        decoration: BoxDecoration(color: Colors.pink[200], borderRadius: BorderRadius.circular(3)),
      );
}

/// Simple dotted border wrapper.
class DottedBorder extends StatelessWidget {
  const DottedBorder({super.key, required this.child, this.color = RimiColors.border, this.radius = 12});
  final Widget child;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DottedBorderPainter(color: color, radius: radius),
      child: ClipRRect(borderRadius: BorderRadius.circular(radius), child: child),
    );
  }
}

class _DottedBorderPainter extends CustomPainter {
  _DottedBorderPainter({required this.color, required this.radius});
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );
    // Draw dashed via Path metrics
    final path = Path()..addRRect(rrect);
    const dash = 6.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final len = distance + dash > metric.length ? metric.length - distance : dash;
        canvas.drawPath(metric.extractPath(distance, distance + len), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DottedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
