import 'package:flutter/material.dart';

/// Rimi design tokens from Google Stitch project.
/// https://stitch.withgoogle.com/projects/3601805917375330502
class RimiColors {
  RimiColors._();

  // Brand
  static const Color primary = Color(0xFFBFE3FF); // soft sky blue
  static const Color primaryDark = Color(0xFF7EC8F5);
  static const Color primaryDeep = Color(0xFF3BA4E6);

  static const Color secondary = Color(0xFFFF8B76); // coral
  static const Color secondaryDark = Color(0xFFE56B55);

  static const Color tertiary = Color(0xFFFFC24B); // warm gold / rewards
  static const Color tertiaryDark = Color(0xFFE5A830);

  // Neutrals
  static const Color neutral = Color(0xFF4A5568);
  static const Color neutralSoft = Color(0xFF718096);
  static const Color neutralMuted = Color(0xFFA0AEC0);
  static const Color border = Color(0xFFE2E8F0);
  static const Color surface = Color(0xFFF7FAFC);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF0F7FC);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF1A202C);

  static const Color success = Color(0xFF48BB78);
  static const Color error = Color(0xFFE53E3E);
  static const Color warning = Color(0xFFED8936);
  static const Color info = primaryDeep;

  // Semantic aliases
  static const Color cta = secondary;
  static const Color reward = tertiary;
  static const Color textPrimary = black;
  static const Color textSecondary = neutral;
  static const Color textMuted = neutralMuted;
}
