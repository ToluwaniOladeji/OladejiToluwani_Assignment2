import 'package:flutter/material.dart';
import '../models/enums.dart';

class AppColors {
  static const primary = Color(0xFF0E5E5A);
  static const primaryDark = Color(0xFF0A4441);
  static const primarySoft = Color(0xFFDDEBE8);
  static const background = Color(0xFFF6F3ED);
  static const border = Color(0xFFE6E1D6);
  static const ink = Color(0xFF1B2623);
  static const muted = Color(0xFF6F7A76);
  static const danger = Color(0xFFB3412B);

  static Color status(IncidentStatus s) {
    switch (s) {
      case IncidentStatus.submitted:
        return const Color(0xFFC0821F);
      case IncidentStatus.inReview:
        return const Color(0xFF7457A6);
      case IncidentStatus.inProgress:
        return const Color(0xFF2B6CA3);
      case IncidentStatus.resolved:
        return const Color(0xFF2E7D5B);
    }
  }
}

class AppTheme {
  static OutlineInputBorder _border(Color c, [double w = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: c, width: w),
      );

  static ThemeData get light {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primarySoft,
      onPrimaryContainer: AppColors.primaryDark,
      surface: Colors.white,
      onSurface: AppColors.ink,
      error: AppColors.danger,
      outline: AppColors.border,
    );

    final body = base.textTheme
        .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink);

    // Headings use the system serif (Noto Serif on Android).
    TextStyle serif(double size) => TextStyle(
      fontFamily: 'serif',
      fontFamilyFallback: const ['Georgia', 'Times New Roman'],
      fontSize: size,
      fontWeight: FontWeight.w600,
      color: AppColors.ink,
      height: 1.15,
    );

    final text = body.copyWith(
      headlineLarge: serif(32),
      headlineMedium: serif(26),
      headlineSmall: serif(22),
      titleLarge: serif(19),
      titleMedium:
      body.titleMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 16),
      bodySmall: body.bodySmall?.copyWith(color: AppColors.muted),
    );

    const buttonText = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.ink,
        titleTextStyle: serif(20),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: _border(AppColors.border),
        enabledBorder: _border(AppColors.border),
        focusedBorder: _border(AppColors.primary, 1.6),
        errorBorder: _border(AppColors.danger),
        focusedErrorBorder: _border(AppColors.danger, 1.6),
        hintStyle: const TextStyle(color: AppColors.muted),
        labelStyle: const TextStyle(color: AppColors.muted),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 52),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          minimumSize: const Size(0, 52),
          side: const BorderSide(color: AppColors.border),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme:
      const DividerThemeData(color: AppColors.border, space: 1),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primarySoft,
        labelTextStyle: const WidgetStatePropertyAll(
            TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }
}