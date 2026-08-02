import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/rimi_colors.dart';

/// Maskot Si Rimi — awan kecil dengan mata sparkle, pipi koral, dan senyum.
/// Diturunkan dari Rimi Design System v1.0 (mark-only 220x160).
class RimiMark extends StatelessWidget {
  const RimiMark({super.key, this.size = 48, this.showCheeks = true});

  final double size;
  final bool showCheeks;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 160 / 220),
      painter: _RimiMarkPainter(showCheeks: showCheeks),
    );
  }
}

class _RimiMarkPainter extends CustomPainter {
  _RimiMarkPainter({required this.showCheeks});

  final bool showCheeks;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 220.0;
    canvas.save();
    canvas.scale(s, s);

    // ── Badan awan ──
    final body = Path()
      ..moveTo(52, 148)
      ..arcToPoint(const Offset(46, 92), radius: const Radius.circular(28))
      ..arcToPoint(const Offset(96, 52), radius: const Radius.circular(36))
      ..arcToPoint(const Offset(172, 82), radius: const Radius.circular(46))
      ..arcToPoint(const Offset(176, 148), radius: const Radius.circular(34))
      ..close();
    canvas.drawPath(body, Paint()..color = RimiColors.cloud);

    // ── Perut (strip bawah, di-clip ke badan) ──
    final belly = Path()
      ..addRect(const Rect.fromLTWH(30, 128, 170, 30));
    final clip = Path.from(body);
    final bellyPaint = Paint()..color = RimiColors.cloudDark;
    canvas.save();
    canvas.clipPath(clip);
    canvas.drawPath(belly, bellyPaint);
    canvas.restore();

    // ── Pipi koral ──
    if (showCheeks) {
      final cheekPaint = Paint()..color = RimiColors.coral.withValues(alpha: 0.85);
      canvas.drawOval(
        const Rect.fromLTWH(46, 103.5, 28, 17),
        cheekPaint,
      );
      canvas.drawOval(
        const Rect.fromLTWH(156, 103.5, 28, 17),
        cheekPaint,
      );
    }

    // ── Mata nila dengan sparkle ──
    final eyePaint = Paint()..color = RimiColors.navy;
    canvas.drawCircle(const Offset(90, 95), 15, eyePaint);
    canvas.drawCircle(const Offset(140, 95), 15, eyePaint);

    final sparklePaint = Paint()..color = RimiColors.white;
    for (final pos in [const Offset(88, 93), const Offset(142, 93)]) {
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.scale(0.78, 0.78);
      final sparkle = Path()
        ..moveTo(0, -9.5)
        ..cubicTo(1.6, -3, 3, -1.6, 9.5, 0)
        ..cubicTo(3, 1.6, 1.6, 3, 0, 9.5)
        ..cubicTo(-1.6, 3, -3, 1.6, -9.5, 0)
        ..cubicTo(-3, -1.6, -1.6, -3, 0, -9.5)
        ..close();
      canvas.drawPath(sparkle, sparklePaint);
      canvas.restore();
    }
    canvas.drawCircle(const Offset(97, 101), 2.6, Paint()..color = RimiColors.white.withValues(alpha: 0.9));
    canvas.drawCircle(const Offset(147, 101), 2.6, Paint()..color = RimiColors.white.withValues(alpha: 0.9));

    // ── Senyum ──
    final smile = Path()
      ..moveTo(107, 122)
      ..quadraticBezierTo(115, 130, 123, 122);
    final smilePaint = Paint()
      ..color = RimiColors.navy
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.6
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(smile, smilePaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RimiMarkPainter oldDelegate) =>
      oldDelegate.showCheeks != showCheeks;
}

/// Logo lengkap: maskot + teks "Si Rimi" (Nunito 900, nila).
class RimiLogoLockup extends StatelessWidget {
  const RimiLogoLockup({
    super.key,
    this.markSize = 40,
    this.fontSize = 22,
    this.color = RimiColors.navy,
    this.horizontal = false,
  });

  final double markSize;
  final double fontSize;
  final Color color;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final mark = RimiMark(size: markSize);
    final text = Text(
      'Si Rimi',
      style: GoogleFonts.nunito(
        fontWeight: FontWeight.w900,
        fontSize: fontSize,
        color: color,
        letterSpacing: -0.5,
        height: 1.1,
      ),
    );

    if (horizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [mark, const SizedBox(width: 10), text],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [mark, const SizedBox(height: 8), text],
    );
  }
}
