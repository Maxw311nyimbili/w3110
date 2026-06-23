// lib/core/theme/app_theme.dart
// Naiia Brand — Warm Ivory Light + Ink Dark

import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_shadows.dart';
import 'package:cap_project/core/theme/app_spacing.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Custom page transition: fade + gentle upward slide ──────────────────────
// Used everywhere instead of the default push. Much more premium.
class _FadeSlidePageTransitionsBuilder extends PageTransitionsBuilder {
  const _FadeSlidePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final fadeIn = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
    final slideIn = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
    final fadeOut = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeIn),
    );

    return FadeTransition(
      opacity: fadeOut,
      child: FadeTransition(
        opacity: fadeIn,
        child: SlideTransition(position: slideIn, child: child),
      ),
    );
  }
}

const _pageTransition = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: _FadeSlidePageTransitionsBuilder(),
    TargetPlatform.iOS: _FadeSlidePageTransitionsBuilder(),
    TargetPlatform.macOS: _FadeSlidePageTransitionsBuilder(),
    TargetPlatform.windows: _FadeSlidePageTransitionsBuilder(),
    TargetPlatform.linux: _FadeSlidePageTransitionsBuilder(),
  },
);

class AppTheme {
  AppTheme._();

  // ─── Light Theme ─────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      platform: TargetPlatform.iOS,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      fontFamily: GoogleFonts.poppins().fontFamily,

      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(
          AppColors.slateBlue.withOpacity(0.3),
        ),
        trackColor: WidgetStateProperty.all(Colors.transparent),
        thickness: WidgetStateProperty.all(4),
        radius: const Radius.circular(3),
        interactive: true,
      ),

      textSelectionTheme: const TextSelectionThemeData(
        selectionColor: AppColors.accentLight,
        selectionHandleColor: AppColors.slateBlue,
        cursorColor: AppColors.slateBlue,
      ),

      pageTransitionsTheme: _pageTransition,

      colorScheme: const ColorScheme.light(
        primary: AppColors.slateBlue,
        onPrimary: Colors.white,
        secondary: AppColors.deepBlue,
        onSecondary: Colors.white,
        tertiary: AppColors.warmTaupe,
        onTertiary: AppColors.ink,
        error: AppColors.error,
        onError: Colors.white,
        surface: AppColors.backgroundSurface,    // warm cream — cards, sheets
        onSurface: AppColors.ink,
        outline: AppColors.borderLight,
        outlineVariant: AppColors.backgroundPanel,
      ),

      // Monochromatic ivory scale — same step logic as dark mode.
      scaffoldBackgroundColor: AppColors.backgroundCanvas,

      // ─── AppBar ──────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.backgroundCanvas,
        foregroundColor: AppColors.ink,
        surfaceTintColor: Colors.transparent,
        shape: const Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 0.5),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: AppColors.backgroundCanvas,
        ),
        titleTextStyle: AppTextStyles.headlineMedium.copyWith(
          color: AppColors.ink,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.ink,
          size: 22,
        ),
      ),

      // ─── Card ─────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          side: const BorderSide(color: AppColors.borderLight, width: 0.75),
        ),
        color: AppColors.backgroundSurface,   // warm cream card bg
        margin: EdgeInsets.zero,
        shadowColor: Colors.transparent,
      ),

      // ─── Inputs ───────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundElevated,  // slightly lighter warm cream
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
            color: AppColors.slateBlue,
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
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.slateBlue.withOpacity(0.4);
            }
            return AppColors.slateBlue;
          }),
          foregroundColor: WidgetStateProperty.all(Colors.white),
          overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(0.12)),
          elevation: WidgetStateProperty.all(0),
          shadowColor: WidgetStateProperty.all(Colors.transparent),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
          ),
          textStyle: WidgetStateProperty.all(
            AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          animationDuration: const Duration(milliseconds: 160),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.slateBlue,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.slateBlue,
          side: const BorderSide(color: AppColors.slateBlue, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      // ─── FAB ──────────────────────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.slateBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
      ),

      // ─── Divider ──────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 0.8,
        space: 1,
      ),

      // ─── Icons ────────────────────────────────────────────────────────────
      iconTheme: const IconThemeData(
        color: AppColors.textSecondary,
        size: 22,
      ),

      // ─── Bottom Sheet ─────────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.backgroundElevated,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl),
          ),
        ),
        elevation: 0,
        surfaceTintColor: AppColors.backgroundElevated,
      ),

      // ─── Chip ─────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.backgroundElevated,
        selectedColor: AppColors.accentLight,
        labelStyle: AppTextStyles.labelMedium.copyWith(
          color: AppColors.textPrimary,
        ),
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
        displayLarge:  AppTextStyles.displayLarge.copyWith(color: AppColors.ink),
        displayMedium: AppTextStyles.displayMedium.copyWith(color: AppColors.ink),
        displaySmall:  AppTextStyles.displaySmall.copyWith(color: AppColors.ink),
        headlineLarge: AppTextStyles.headlineLarge.copyWith(color: AppColors.ink),
        headlineMedium: AppTextStyles.headlineMedium.copyWith(color: AppColors.ink),
        headlineSmall: AppTextStyles.headlineSmall.copyWith(color: AppColors.ink),
        bodyLarge:   AppTextStyles.bodyLarge.copyWith(color: AppColors.ink),
        bodyMedium:  AppTextStyles.bodyMedium.copyWith(color: AppColors.ink),
        bodySmall:   AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        labelLarge:  AppTextStyles.labelLarge.copyWith(color: AppColors.ink),
        labelMedium: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
        labelSmall:  AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
      ),
    );
  }

  // ─── Dark Theme — Naiia Midnight Slate ───────────────────────────────────
  //
  // Palette:
  //   Canvas #0D1520 → Surface #131E2F → Elevated #192638 → Modal #1F3047
  //   Primary: #9BBBD8 (luminous sky-slate, high contrast on midnight bg)
  //   Taupe accent: #CEBFB0 (warm pop against cool slate)
  //   Text: #EEF2F7 / #A0B0C4 / #607080
  //   Borders: slate-blue at 22% / 10% opacity
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      platform: TargetPlatform.iOS,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      fontFamily: GoogleFonts.poppins().fontFamily,

      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(
          AppColors.darkPrimary.withOpacity(0.35),
        ),
        trackColor: WidgetStateProperty.all(Colors.transparent),
        thickness: WidgetStateProperty.all(4),
        radius: const Radius.circular(3),
        interactive: true,
      ),

      textSelectionTheme: const TextSelectionThemeData(
        selectionColor: AppColors.darkPrimaryContainer,
        selectionHandleColor: AppColors.darkPrimary,
        cursorColor: AppColors.darkPrimary,
      ),

      pageTransitionsTheme: _pageTransition,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkPrimary,           // #BACADC — luminous slate blue
        onPrimary: AppColors.darkOnPrimary,        // #1A2430 — deep ink on primary
        primaryContainer: AppColors.darkPrimaryContainer, // #2A3D52
        onPrimaryContainer: AppColors.darkPrimary,
        secondary: AppColors.darkTaupe,            // #D6CABF — warm taupe accent
        onSecondary: AppColors.darkCanvas,         // deep ink on taupe
        tertiary: AppColors.darkTextSecondary,     // warm mid-grey as tertiary
        onTertiary: AppColors.darkCanvas,
        error: AppColors.error,
        onError: Colors.white,
        surface: AppColors.darkSurface,            // #201D16 — card bg
        onSurface: AppColors.darkTextPrimary,      // #F0EBE2
        outline: AppColors.darkBorder,             // taupe at 27%
        outlineVariant: AppColors.darkBorderSubtle, // taupe at 12%
      ),

      scaffoldBackgroundColor: AppColors.darkCanvas,

      // ─── AppBar ────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.darkCanvas,
        foregroundColor: AppColors.darkTextPrimary,
        surfaceTintColor: Colors.transparent,
        shape: const Border(
          bottom: BorderSide(color: AppColors.darkBorder, width: 0.5),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: AppTextStyles.headlineMedium.copyWith(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.darkTextPrimary,
          size: 22,
        ),
      ),

      // ─── Card ──────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          side: const BorderSide(color: AppColors.darkBorder, width: 0.5),
        ),
        color: AppColors.darkSurface,
        margin: EdgeInsets.zero,
        shadowColor: Colors.transparent,
      ),

      // ─── Bottom Sheet ──────────────────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkModal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl),
          ),
        ),
        elevation: 0,
        surfaceTintColor: AppColors.darkModal,
      ),

      // ─── Inputs ────────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkElevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.darkPrimary, width: 1.5),
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
          color: AppColors.darkTextTertiary,
        ),
        labelStyle: AppTextStyles.labelMedium.copyWith(
          color: AppColors.darkTextSecondary,
        ),
      ),

      // ─── Buttons ───────────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.darkPrimary.withOpacity(0.4);
            }
            return AppColors.darkPrimary;
          }),
          foregroundColor: WidgetStateProperty.all(AppColors.darkOnPrimary),
          overlayColor: WidgetStateProperty.all(AppColors.darkOnPrimary.withOpacity(0.10)),
          elevation: WidgetStateProperty.all(0),
          shadowColor: WidgetStateProperty.all(Colors.transparent),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
          ),
          textStyle: WidgetStateProperty.all(
            AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          animationDuration: const Duration(milliseconds: 160),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkPrimary,
          side: const BorderSide(color: AppColors.darkPrimary, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      // ─── FAB ───────────────────────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: AppColors.darkOnPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
      ),

      // ─── Divider ───────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 0.8,
        space: 1,
      ),

      // ─── Icons ─────────────────────────────────────────────────────────────
      iconTheme: const IconThemeData(
        color: AppColors.darkTextSecondary,
        size: 22,
      ),

      // ─── Chips ─────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkElevated,
        selectedColor: AppColors.darkPrimaryContainer,
        labelStyle: AppTextStyles.labelMedium.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        side: const BorderSide(color: AppColors.darkBorder),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
      ),

      // ─── Text theme ────────────────────────────────────────────────────────
      textTheme: TextTheme(
        displayLarge:   AppTextStyles.displayLarge.copyWith(color: AppColors.darkTextPrimary),
        displayMedium:  AppTextStyles.displayMedium.copyWith(color: AppColors.darkTextPrimary),
        displaySmall:   AppTextStyles.displaySmall.copyWith(color: AppColors.darkTextPrimary),
        headlineLarge:  AppTextStyles.headlineLarge.copyWith(color: AppColors.darkTextPrimary),
        headlineMedium: AppTextStyles.headlineMedium.copyWith(color: AppColors.darkTextPrimary),
        headlineSmall:  AppTextStyles.headlineSmall.copyWith(color: AppColors.darkTextPrimary),
        bodyLarge:      AppTextStyles.bodyLarge.copyWith(color: AppColors.darkTextPrimary),
        bodyMedium:     AppTextStyles.bodyMedium.copyWith(color: AppColors.darkTextPrimary),
        bodySmall:      AppTextStyles.bodySmall.copyWith(color: AppColors.darkTextSecondary),
        labelLarge:     AppTextStyles.labelLarge.copyWith(color: AppColors.darkTextPrimary),
        labelMedium:    AppTextStyles.labelMedium.copyWith(color: AppColors.darkTextSecondary),
        labelSmall:     AppTextStyles.labelSmall.copyWith(color: AppColors.darkTextTertiary),
      ),
    );
  }
}
