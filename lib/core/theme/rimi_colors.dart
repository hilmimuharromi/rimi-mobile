import 'package:flutter/material.dart';

/// Rimi design tokens — matched to Google Stitch design.
/// https://stitch.withgoogle.com/projects/3601805917375330502
class RimiColors {
  RimiColors._();

  // Brand — Teal (Si Rimi mascot circle, cashback badges)
  static const Color primary = Color(0xFF2ABFA4); // teal green
  static const Color primaryDark = Color(0xFF23A08A);
  static const Color primaryDeep = Color(0xFF1B8A76);
  static const Color primarySoft = Color(0xFFCFF0E8);

  // Secondary — Coral / Orange (hero banner, prices, CTA highlight)
  static const Color secondary = Color(0xFFF07040); // coral
  static const Color secondaryDark = Color(0xFFE8734A);
  static const Color secondarySoft = Color(0xFFFDCFB0);
  static const Color secondaryDeep = Color(0xFFD4842A);

  // Tertiary — Warm Gold (rewards / Poinku)
  static const Color tertiary = Color(0xFFFFC24B);
  static const Color tertiaryDark = Color(0xFFE5A830);

  // Hero banner gradient
  static const Color heroStart = Color(0xFFF5A623);
  static const Color heroEnd = Color(0xFFFDD5B5);

  // Neutrals — softened
  static const Color neutral = Color(0xFF2D2D2D);
  static const Color neutralSoft = Color(0xFF666666);
  static const Color neutralMuted = Color(0xFFAAAAAA);
  static const Color border = Color(0xFFE0E0E0);
  static const Color surface = Color(0xFFF7FAFC);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFFAFAFA);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF2D2D2D);

  static const Color success = Color(0xFF2ABFA4);
  static const Color error = Color(0xFFE53E3E);
  static const Color warning = Color(0xFFED8936);
  static const Color info = primaryDeep;

  // Semantic aliases
  static const Color cta = secondary;
  static const Color reward = tertiary;
  static const Color textPrimary = black;
  static const Color textSecondary = neutralSoft;
  static const Color textMuted = neutralMuted;

  // Bottom nav
  static const Color navActive = secondary;
  static const Color navInactive = neutralMuted;
}
