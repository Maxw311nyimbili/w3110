// lib/core/theme/app_colors.dart
// Hope UI Inspired — Warm Light Palette for Maternal Health

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Backgrounds (Premium Neutral & Tinted Scale) ─────────────────────────
  static const Color backgroundPrimary = Color(0xFFF8FAFA); // Even lighter off-white teal-tint
  static const Color backgroundSurface = Color(0xFFFFFFFF); // Clean cards
  static const Color backgroundElevated = Color(0xFFFFFFFF); // Clean white (Apple/Sidebar)
  static const Color backgroundSecondary = Color(0xFFF5F7F7); // Subtle tint

  // ─── Brand — Teal Identity ─────────────────────────────────────────────────
  static const Color accentPrimary = Color(
    0xFF0C7E8A,
  ); // Vibrant teal (CTAs, active)
  static const Color accentSecondary = Color(
    0xFF0C4B4F,
  ); // Deep teal (hover, pressed)
  static const Color accentLight = Color(
    0xFFD6F0F2,
  ); // Teal tint (badges, highlights)
  static const Color brandDarkTeal = Color(
    0xFF0C4B4F,
  ); // Keep for compatibility

  // ─── Text (High-Performance Typography) ───────────────────────────────────
  static const Color textPrimary = Color(0xFF090E0D); // Deep charcoal (Matched to dark-mode background)

  static const Color textSecondary = Color(0xFF374151); // Darker slate-grey
  static const Color textTertiary = Color(0xFF6B7280); // Medium slate-grey
  static const Color textInverted = Color(0xFFFFFFFF); // White text on dark
  static const Color textAccent = Color(0xFF0C7E8A); // Teal text links

  // ─── Borders (Subtle & Hairline) ──────────────────────────────────────────
  static const Color borderLight = Color(0xFFE5E7EB); // Subtle default border
  static const Color borderMedium = Color(0xFFD1D5DB); // Stronger outline
  static const Color borderDark = Color(0xFF374151); // High contrast outline
  static const Color borderAccent = Color(0xFF0C7E8A); // Teal focus border

  // ─── Semantic ──────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF2D9D78); // Calm green
  static const Color info = Color(0xFF3B82C4); // Soft blue
  static const Color warning = Color(0xFFD97706); // Warm amber
  static const Color error = Color(0xFFDC3545); // Clear red

  // ─── Glassmorphism surfaces ─────────────────────────────────────────────────
  static const Color glassLight = Color(
    0x99FFFFFF,
  ); // White glass (60% opacity)
  static const Color glassBorder = Color(
    0x80E8E3DC,
  ); // Warm glass border (50% opacity)
  static const Color glassOverlay = Color(0x0DFFFFFF); // Subtle hover overlay

  // ─── Shadow (Teal-tinted, warm) ────────────────────────────────────────────
  static const Color shadowTeal = Color(0x200C7E8A); // Teal-tinted card shadow
  static const Color shadowWarm = Color(
    0x141C1917,
  ); // Warm-black ambient shadow
  static const Color shadow = Color(0x0A000000); // Legacy neutral soft shadow

  // ─── Dark Mode (Deep "Ink" & Tinted Elevation) ────────────────────────────
  static const Color darkBackgroundPrimary = Color(0xFF090E0D); // Deep charcoal-teal backdrop
  static const Color darkBackgroundSurface = Color(0xFF131C1A); // Slightly lifted card
  static const Color darkBackgroundElevated = Color(0xFF1C2826); // High proximity lift
  static const Color darkTextPrimary = Color(0xFFF8FAFC); // High contrast, anti-halation
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Muted slate
  static const Color darkTextTertiary = Color(0xFF64748B); // Faint/disabled
  static const Color darkBorder = Color(0x1F2B3633); // Subtle inner bordre

  // ─── Compatibility aliases ──────────────────────────────────────────────────
  static const Color gray100 = Color(0xFFD8E0EC); // Elevated/input fill
  static const Color gray200 = Color(0xFFC0CAD8); // Light border
  static const Color gray300 = Color(0xFFA8B5C6); // Medium border
  static const Color gray400 = Color(0xFF94A3B8);

  static const Color confidenceHigh = success;
  static const Color confidenceMedium = warning;
  static const Color confidenceLow = error;

  // ─── Splash palette ────────────────────────────────────────────────────────
  static const Color splashOrange = Color(0xFFFF6719);
  static const Color splashWhite = Color(0xFFFFFFFF);
  static const Color splashDune = Color(0xFF2B2823);
}
