import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'rimi_colors.dart';
import 'rimi_typography.dart';

class RimiTheme {
  RimiTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: RimiColors.primaryDeep,
        onPrimary: RimiColors.white,
        primaryContainer: RimiColors.primary,
        secondary: RimiColors.secondary,
        onSecondary: RimiColors.white,
        tertiary: RimiColors.tertiary,
        onTertiary: RimiColors.black,
        surface: RimiColors.surfaceCard,
        onSurface: RimiColors.textPrimary,
        error: RimiColors.error,
        outline: RimiColors.border,
      ),
      scaffoldBackgroundColor: RimiColors.background,
      textTheme: RimiTypography.textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: RimiColors.navy,
        foregroundColor: RimiColors.white,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: RimiTypography.textTheme.headlineSmall?.copyWith(color: RimiColors.white),
      ),
      cardTheme: CardTheme(
        color: RimiColors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: RimiColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: RimiColors.secondary,
          foregroundColor: RimiColors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: RimiTypography.textTheme.labelLarge?.copyWith(color: RimiColors.white),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: RimiColors.secondary,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: RimiColors.secondary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: RimiTypography.textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: RimiColors.primaryDeep,
          textStyle: RimiTypography.textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: RimiColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: RimiColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: RimiColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: RimiColors.primaryDeep, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: RimiColors.error),
        ),
        hintStyle: RimiTypography.textTheme.bodyMedium?.copyWith(color: RimiColors.textMuted),
        labelStyle: RimiTypography.textTheme.bodyMedium,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: RimiColors.primary.withValues(alpha: 0.5),
        selectedColor: RimiColors.primaryDeep,
        labelStyle: RimiTypography.textTheme.labelMedium!,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: RimiColors.white,
        selectedItemColor: RimiColors.secondary,
        unselectedItemColor: RimiColors.neutralMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showUnselectedLabels: true,
      ),
      dividerTheme: const DividerThemeData(color: RimiColors.border, thickness: 1, space: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: RimiColors.neutral,
        contentTextStyle: RimiTypography.textTheme.bodyMedium?.copyWith(color: RimiColors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    return base;
  }
}
