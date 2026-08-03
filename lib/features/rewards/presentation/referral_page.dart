import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/api/api_client.dart';
import '../../../core/theme/rimi_colors.dart';
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

class ReferralPage extends ConsumerStatefulWidget {
  const ReferralPage({super.key});

  @override
  ConsumerState<ReferralPage> createState() => _ReferralPageState();
}

class _ReferralPageState extends ConsumerState<ReferralPage> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final downlineAsync = ref.watch(referralDownlineProvider);
    final code = auth.user?.referralCode ?? 'RIMI-SAYANG-IBU';

    return Scaffold(
      backgroundColor: RimiColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: RimiColors.primary,
          onRefresh: () async => ref.invalidate(referralDownlineProvider),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ---------- Top App Bar ----------
              const SliverToBoxAdapter(child: _TopBar()),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // ---------- Hero Section ----------
              const SliverToBoxAdapter(child: _HeroSection()),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // ---------- Referral Code Box ----------
              SliverToBoxAdapter(
                child: _ReferralCodeBox(
                  code: code,
                  copied: _copied,
                  onCopy: () async {
                    await Clipboard.setData(ClipboardData(text: code));
                    if (!context.mounted) return;
                    setState(() => _copied = true);
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) setState(() => _copied = false);
                    });
                  },
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // ---------- Teman Terundang ----------
              SliverToBoxAdapter(
                child: _FriendsHeader(downlineAsync: downlineAsync),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // ---------- Friend List ----------
              SliverToBoxAdapter(
                child: _FriendsList(downlineAsync: downlineAsync),
              ),

              // ---------- Ajak Lebih Banyak Button ----------
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                    label: Text(
                      'Ajak Lebih Banyak Lagi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: RimiColors.secondary,
                      side: BorderSide(color: RimiColors.secondary.withValues(alpha: 0.2)),
                      backgroundColor: RimiColors.secondary.withValues(alpha: 0.05),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // ---------- Promotion Banner ----------
              const SliverToBoxAdapter(child: _PromoBanner()),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------- TOP BAR --------------------
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: RimiColors.background,
        boxShadow: [
          BoxShadow(
            color: RimiColors.cloud.withValues(alpha: 0.5),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 40),
          Text(
            'Rimi',
            style: GoogleFonts.quicksand(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: RimiColors.primary,
              letterSpacing: -0.5,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: RimiColors.primary, size: 24),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

// -------------------- HERO SECTION --------------------
class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: RimiColors.cloud,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [
            // Background blur circles
            Positioned(
              top: -32,
              right: -32,
              child: Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -32,
              left: -32,
              child: Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  color: RimiColors.coralSoft.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Content (centered)
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Mascot
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: RimiColors.navy.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.child_care_rounded, size: 56, color: RimiColors.primary),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Untung Bareng Sahabat!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.quicksand(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: RimiColors.primary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ajak teman belanja, kalian berdua dapat\ncashback poin melimpah!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: RimiColors.primary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------- REFERRAL CODE BOX --------------------
class _ReferralCodeBox extends StatelessWidget {
  const _ReferralCodeBox({
    required this.code,
    required this.copied,
    required this.onCopy,
  });

  final String code;
  final bool copied;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DottedBorder(
        color: RimiColors.border,
        radius: 20,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: RimiColors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Text(
                'KODE REFERRAL KAMU',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: RimiColors.primary,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: RimiColors.cloud.withValues(alpha: 0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: RimiColors.navy.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        code,
                        style: GoogleFonts.quicksand(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: RimiColors.primary,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: onCopy,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: copied
                              ? const Color(0xFF2D6A4F).withValues(alpha: 0.1)
                              : RimiColors.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              copied ? Icons.check_rounded : Icons.copy_rounded,
                              size: 16,
                              color: copied ? const Color(0xFF2D6A4F) : RimiColors.secondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              copied ? 'Tersalin' : 'Salin',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: copied ? const Color(0xFF2D6A4F) : RimiColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Bagikan kode ini dan dapatkan 10.000 Poin untuk tiap teman yang bergabung.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: RimiColors.neutralMuted,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------- FRIENDS HEADER --------------------
class _FriendsHeader extends StatelessWidget {
  const _FriendsHeader({required this.downlineAsync});
  final AsyncValue<List<Map<String, dynamic>>> downlineAsync;

  @override
  Widget build(BuildContext context) {
    final count = downlineAsync.maybeWhen(data: (d) => d.length, orElse: () => 0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            'Teman Terundang',
            style: GoogleFonts.quicksand(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: RimiColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: RimiColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count Teman',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------- FRIENDS LIST --------------------
class _FriendsList extends StatelessWidget {
  const _FriendsList({required this.downlineAsync});
  final AsyncValue<List<Map<String, dynamic>>> downlineAsync;

  @override
  Widget build(BuildContext context) {
    return downlineAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))),
      ),
      error: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text('Gagal memuat data teman',
            style: GoogleFonts.plusJakartaSans(color: RimiColors.error, fontSize: 14)),
      ),
      data: (list) {
        if (list.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.people_outline_rounded, size: 48, color: RimiColors.neutralMuted),
                  const SizedBox(height: 8),
                  Text(
                    'Belum ada teman terundang',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: RimiColors.neutralMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: list.map((d) => _buildTile(d)).toList(),
          ),
        );
      },
    );
  }

  Widget _buildTile(Map<String, dynamic> d) {
    final name = d['full_name']?.toString() ?? 'Member';
    final orderCount = (d['order_count'] as num?)?.toInt() ?? 0;
    final joined = d['joined_at']?.toString() ?? '';
    final active = orderCount > 0;

    return _FriendTile(
      name: name,
      subtitle: active ? 'Bergabung $joined' : 'Menunggu transaksi pertama',
      points: active ? '+5.000 Pts' : '--',
      status: active ? 'Berhasil' : 'Proses',
      isActive: active,
    );
  }
}

class _FriendTile extends StatelessWidget {
  const _FriendTile({
    required this.name,
    required this.subtitle,
    required this.points,
    required this.status,
    required this.isActive,
  });

  final String name;
  final String subtitle;
  final String points;
  final String status;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: RimiColors.navy.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: RimiColors.cloud,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_rounded, color: RimiColors.primary, size: 22),
          ),
          const SizedBox(width: 16),
          // Name + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: RimiColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: RimiColors.neutralMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Points + status badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                points,
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isActive ? RimiColors.tertiary : RimiColors.neutralMuted,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF2D6A4F).withValues(alpha: 0.1) : const Color(0xFFFF9800).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isActive ? const Color(0xFF2D6A4F) : const Color(0xFFFF9800),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// -------------------- PROMO BANNER --------------------
class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD99A), Color(0xFFFFEDEA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: RimiColors.navy.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background star icon
            Positioned(
              top: 0,
              right: 0,
              child: Icon(
                Icons.star_rounded,
                size: 100,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            // Content
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kejar Bonus Poin\nAkhir Bulan!',
                        style: GoogleFonts.quicksand(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF5E4200),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Hingga 50.000 Poin Tambahan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF5E4200).withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Lihat Detail',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: RimiColors.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple dotted border wrapper (kept from original).
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
    final path = Path()..addRRect(rrect);
    const dash = 8.0;
    const gap = 8.0;
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
