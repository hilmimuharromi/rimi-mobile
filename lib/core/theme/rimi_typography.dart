import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'rimi_colors.dart';

/// Typography: Nunito (headline/angka/label tombol) + Plus Jakarta Sans (body/label).
///
/// Exposes both a full [textTheme] and static convenience getters so widgets
/// can write `RimiTypography.titleLarge` instead of
/// `RimiTypography.textTheme.titleLarge!`.
class RimiTypography {
  RimiTypography._();

  // ---------- Static convenience styles ----------
  static TextStyle get displayLarge => GoogleFonts.nunito(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: RimiColors.textPrimary,
        height: 1.15,
      );

  static TextStyle get displayMedium => GoogleFonts.nunito(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: RimiColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get displaySmall => GoogleFonts.nunito(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: RimiColors.textPrimary,
      );

  static TextStyle get headlineLarge => GoogleFonts.nunito(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: RimiColors.textPrimary,
      );

  static TextStyle get headlineMedium => GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: RimiColors.textPrimary,
      );

  static TextStyle get headlineSmall => GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: RimiColors.textPrimary,
      );

  static TextStyle get titleLarge => GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: RimiColors.textPrimary,
      );

  static TextStyle get titleMedium => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: RimiColors.textPrimary,
      );

  static TextStyle get titleSmall => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: RimiColors.textPrimary,
      );

  static TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: RimiColors.textSecondary,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: RimiColors.textSecondary,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: RimiColors.textMuted,
        height: 1.4,
      );

  static TextStyle get labelLarge => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: RimiColors.textPrimary,
      );

  static TextStyle get labelMedium => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: RimiColors.textPrimary,
      );

  static TextStyle get labelSmall => GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: RimiColors.textMuted,
      );

  /// Caption / helper text (alias of bodySmall-ish).
  static TextStyle get caption => GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: RimiColors.textMuted,
        height: 1.3,
      );

  /// Full Material TextTheme for ThemeData.
  static TextTheme get textTheme => TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        displaySmall: displaySmall,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      );
}
