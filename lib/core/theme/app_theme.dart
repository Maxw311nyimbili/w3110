// lib/core/theme/app_theme.dart
// Hope UI Inspired — Warm Light Theme

import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_spacing.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  AppTheme._();

  // ─── Light Theme ─────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      platform: TargetPlatform.iOS,

      textSelectionTheme: const TextSelectionThemeData(
        selectionColor: AppColors.accentLight,
        selectionHandleColor: AppColors.accentPrimary,
        cursorColor: AppColors.accentPrimary,
      ),

      // iOS-style slide transitions everywhere for premium feel
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      colorScheme: const ColorScheme.light(
        primary: AppColors.accentPrimary,
        onPrimary: Colors.white,
        secondary: AppColors.accentSecondary,
        onSecondary: Colors.white,
        error: AppColors.error,
        onError: Colors.white,
        surface: AppColors.backgroundSurface,
        onSurface: AppColors.textPrimary,
        outline: AppColors.borderLight,
        outlineVariant: AppColors.backgroundElevated,
      ),

      scaffoldBackgroundColor: AppColors.backgroundPrimary,

      // ─── AppBar ──────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.backgroundPrimary,
        foregroundColor: AppColors.textPrimary,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: AppColors.backgroundPrimary,
        ),
        titleTextStyle: AppTextStyles.headlineMedium,
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: 22,
        ),
      ),

      // ─── Card ─────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
        color: AppColors.backgroundSurface,
        margin: EdgeInsets.zero,
      ),

      // ─── Inputs ───────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundElevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(
            color: AppColors.borderLight,
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(
            color: AppColors.borderLight,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(
            color: AppColors.accentPrimary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textTertiary,
        ),
        labelStyle: AppTextStyles.labelMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),

      // ─── Buttons ──────────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          textStyle: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accentPrimary,
          side: const BorderSide(color: AppColors.accentPrimary, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      // ─── FAB ──────────────────────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentPrimary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
      ),

      // ─── Divider ──────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
        space: 1,
      ),

      // ─── Icons ────────────────────────────────────────────────────────────
      iconTheme: const IconThemeData(
        color: AppColors.textSecondary,
        size: 22,
      ),

      // ─── Bottom sheet ─────────────────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.backgroundSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl),
          ),
        ),
        elevation: 0,
        modalElevation: 0,
      ),

      // ─── Chip ─────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.backgroundElevated,
        selectedColor: AppColors.accentLight,
        labelStyle: AppTextStyles.labelMedium,
        side: const BorderSide(color: AppColors.borderLight),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
      ),

      // ─── Text theme ───────────────────────────────────────────────────────
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        displaySmall: AppTextStyles.displaySmall,
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),
    );
  }

  // ─── Dark Theme (preserved for opt-in) ───────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      platform: TargetPlatform.iOS,

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentPrimary,
        onPrimary: Colors.white,
        secondary: AppColors.accentSecondary,
        onSecondary: Colors.white,
        error: AppColors.error,
        onError: Colors.white,
        surface: AppColors.darkBackgroundSurface,
        onSurface: AppColors.darkTextPrimary,
        outline: AppColors.borderDark,
        outlineVariant: AppColors.darkBackgroundPrimary,
      ),

      scaffoldBackgroundColor: AppColors.darkBackgroundPrimary,

      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.darkBackgroundPrimary,
        foregroundColor: AppColors.darkTextPrimary,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: AppTextStyles.headlineMedium.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.darkTextPrimary,
          size: 22,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: BorderSide(color: AppColors.borderDark.withOpacity(0.4)),
        ),
        color: AppColors.darkBackgroundSurface,
        margin: EdgeInsets.zero,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkBackgroundElevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: AppColors.borderDark.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: AppColors.borderDark.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(
            color: AppColors.accentPrimary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.darkTextTertiary,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.accentPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentPrimary,
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentPrimary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: AppColors.borderDark.withOpacity(0.3),
        thickness: 1,
        space: 1,
      ),

      iconTheme: const IconThemeData(
        color: AppColors.darkTextSecondary,
        size: 22,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkBackgroundElevated,
        selectedColor: AppColors.accentSecondary,
        labelStyle: AppTextStyles.labelMedium.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        side: BorderSide(color: AppColors.borderDark.withOpacity(0.3)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
      ),

      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        displayMedium: AppTextStyles.displayMedium.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        displaySmall: AppTextStyles.displaySmall.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        headlineLarge: AppTextStyles.headlineLarge.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        headlineMedium: AppTextStyles.headlineMedium.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        headlineSmall: AppTextStyles.headlineSmall.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        bodySmall: AppTextStyles.bodySmall.copyWith(
          color: AppColors.darkTextSecondary,
        ),
        labelLarge: AppTextStyles.labelLarge.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        labelMedium: AppTextStyles.labelMedium.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        labelSmall: AppTextStyles.labelSmall.copyWith(
          color: AppColors.darkTextSecondary,
        ),
      ),
    );
  }
}
