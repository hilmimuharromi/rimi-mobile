import 'package:flutter/material.dart';

/// Rimi design tokens — Si Rimi Design System v1.0.
/// Awan / Nila / Koral / Kapas — e-commerce bayi & anak.
class RimiColors {
  RimiColors._();

  // ── Nila (navy) — logo, judul, garis ikon, teks utama ──
  static const Color navy = Color(0xFF34517E);
  static const Color navyDark = Color(0xFF25405F);
  static const Color navyDeep = Color(0xFF1E2C45);
  static const Color navyLight = Color(0xFF5C6B84);
  static const Color navyMuted = Color(0xFF93A2B8);

  // ── Koral (coral) — CTA, pipi, harga promo. Max 1 per layar ──
  static const Color coral = Color(0xFFF97A6D);
  static const Color coralDark = Color(0xFFE15A4C);
  static const Color coralDeep = Color(0xFFB2402F);
  static const Color coralSoft = Color(0xFFFFEDEA);

  // ── Awan (cloud) — badan maskot, latar seksi, kartu tenang ──
  static const Color cloud = Color(0xFFE3F0FB);
  static const Color cloudLight = Color(0xFFF3F9FE);
  static const Color cloudDark = Color(0xFFC9E1F6);

  // ── Kapas (paper) — latar aplikasi ──
  static const Color paper = Color(0xFFFBFAF7);
  static const Color paperDark = Color(0xFFF1EFE9);

  // ── Netral ──
  static const Color neutral = Color(0xFF1E2C45);
  static const Color neutralSoft = Color(0xFF5C6B84);
  static const Color neutralMuted = Color(0xFF93A2B8);
  static const Color border = Color(0xFFE2E0D9);
  static const Color surface = Color(0xFFF3F9FE);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFFBFAF7);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF1E2C45);

  // ── Dukungan ──
  static const Color success = Color(0xFF4B8B5E);
  static const Color successSoft = Color(0xFFF3FAF4);
  static const Color error = Color(0xFFE15A4C);
  static const Color warning = Color(0xFFF9C74F);
  static const Color info = Color(0xFF5D8CC2);

  // Semantic aliases (backward compat dengan kode lama)
  static const Color primary = navy;
  static const Color primaryDark = navyDark;
  static const Color primaryDeep = navyDeep;
  static const Color primarySoft = cloudLight;
  static const Color secondary = coral;
  static const Color secondaryDark = coralDark;
  static const Color secondarySoft = coralSoft;
  static const Color secondaryDeep = coralDeep;
  static const Color tertiary = warning;
  static const Color tertiaryDark = Color(0xFFE5A830);
  static const Color cta = coral;
  static const Color reward = warning;
  static const Color textPrimary = navyDeep;
  static const Color textSecondary = navyLight;
  static const Color textMuted = navyMuted;
  static const Color navActive = coral;
  static const Color navInactive = navyMuted;

  // Hero banner gradient — cloud → coral tint
  static const Color heroStart = Color(0xFFE3F0FB);
  static const Color heroEnd = Color(0xFFFFEDEA);
}
