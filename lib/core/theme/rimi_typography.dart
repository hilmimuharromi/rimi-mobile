import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'rimi_colors.dart';

/// Typography: Quicksand (headline) + Plus Jakarta Sans (body/label).
class RimiTypography {
  RimiTypography._();

  static TextTheme textTheme = TextTheme(
    displayLarge: GoogleFonts.quicksand(
      fontSize: 40,
      fontWeight: FontWeight.w700,
      color: RimiColors.textPrimary,
      height: 1.15,
    ),
    displayMedium: GoogleFonts.quicksand(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: RimiColors.textPrimary,
      height: 1.2,
    ),
    displaySmall: GoogleFonts.quicksand(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: RimiColors.textPrimary,
    ),
    headlineLarge: GoogleFonts.quicksand(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: RimiColors.textPrimary,
    ),
    headlineMedium: GoogleFonts.quicksand(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: RimiColors.textPrimary,
    ),
    headlineSmall: GoogleFonts.quicksand(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: RimiColors.textPrimary,
    ),
    titleLarge: GoogleFonts.plusJakartaSans(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: RimiColors.textPrimary,
    ),
    titleMedium: GoogleFonts.plusJakartaSans(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: RimiColors.textPrimary,
    ),
    titleSmall: GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: RimiColors.textPrimary,
    ),
    bodyLarge: GoogleFonts.plusJakartaSans(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: RimiColors.textSecondary,
      height: 1.5,
    ),
    bodyMedium: GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: RimiColors.textSecondary,
      height: 1.5,
    ),
    bodySmall: GoogleFonts.plusJakartaSans(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: RimiColors.textMuted,
      height: 1.4,
    ),
    labelLarge: GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: RimiColors.textPrimary,
    ),
    labelMedium: GoogleFonts.plusJakartaSans(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: RimiColors.textSecondary,
    ),
    labelSmall: GoogleFonts.plusJakartaSans(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: RimiColors.textMuted,
    ),
  );
}
