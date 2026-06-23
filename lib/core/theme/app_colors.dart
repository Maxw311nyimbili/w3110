// lib/core/theme/app_colors.dart
// Naiia Brand — v2 color system
//
// Strategy:
//   Light  — warm ivory canvas, STARK WHITE surfaces for contrast, bold ink text.
//            The brand's dusty blue/taupe appear as accents, not the whole canvas.
//   Dark   — MIDNIGHT SLATE (deep navy-blue), NOT muddy brown.
//            Complements the brand's cool-blue side; taupe becomes a warm accent pop.

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Brand Core (from brand guide, unchanged) ─────────────────────────────
  /// Slate Blue — primary / wordmark / CTAs / active nav
  static const Color slateBlue = Color(0xFF7B91AD);

  /// Deep Blue — text on light, dark UI, pressed / hover state
  static const Color deepBlue = Color(0xFF5F7491);

  /// Warm Taupe — symbol fill, accents
  static const Color warmTaupe = Color(0xFFC9BBAC);

  /// Warm Ivory — page canvas
  static const Color warmIvory = Color(0xFFF8F6EF);

  /// Ink — primary body text (neutral near-black — no warm undertone)
  static const Color ink = Color(0xFF18181B);

  // ─── Deep Taupe — DECORATIVE / BRAND ACCENT ONLY ─────────────────────────
  /// Use for brand mark fills, icon accents, decorative elements.
  /// Do NOT use for readable text — it reads as brown on light backgrounds.
  static const Color deepTaupe = Color(0xFF7A6E64);

  // ─── Semantic aliases ─────────────────────────────────────────────────────
  static const Color accentPrimary = slateBlue;
  static const Color accentSecondary = deepBlue;
  static const Color accentLight = Color(0xFFDDE4EC);
  static const Color brandDarkTeal = deepBlue;

  // ─── Light Mode — Monochromatic Warm Ivory Scale ─────────────────────────
  //
  // Same philosophy as dark mode's midnight-slate steps.
  // All layers are the same warm cream family — no pure white.
  // Each step is ~6 lightness units lighter, creating visible depth
  // without any colour-family clash.
  //
  //   Dark equivalent  →  Light equivalent
  //   darkCanvas       →  backgroundCanvas   (page scaffold)
  //   darkSurface      →  backgroundPanel    (sidebar, panels)
  //   darkElevated     →  backgroundSurface  (cards, list items)
  //   darkModal        →  backgroundElevated (inputs, inner fields)

  /// Deepest layer — page scaffold / canvas
  static const Color backgroundCanvas = Color(0xFFE4DDD0);

  /// Sidebar, nav panels — one step lighter than canvas
  static const Color backgroundPanel = Color(0xFFECE7DB);

  /// Cards, bubbles, list items — clearly lighter than canvas
  static const Color backgroundSurface = Color(0xFFF3EFE6);

  /// Inputs, inner surfaces — lightest interactive layer
  static const Color backgroundElevated = Color(0xFFF8F4EC);

  /// Alias kept for legacy compat
  static const Color backgroundPrimary = backgroundCanvas;
  static const Color backgroundSecondary = backgroundPanel;

  // ─── Light Mode Text ──────────────────────────────────────────────────────
  // Strategy: NEUTRAL greys — no warm undertone → won't read as "brown".
  // The warm ivory canvas supplies all the warmth the page needs.
  //
  /// Near-black neutral ink — strong contrast, no brown cast
  static const Color textPrimary = ink; // #18181B (Zinc 900)
  /// Strong secondary — neutral dark grey (not brown)
  static const Color textSecondary = Color(0xFF404348); // neutral dark grey
  /// Tertiary — neutral mid-grey, clearly legible
  static const Color textTertiary = Color(0xFF6E7278); // neutral cool grey
  static const Color textInverted = Color(0xFFF5F2EC);
  static const Color textAccent = slateBlue;

  // ─── Light Mode Borders ───────────────────────────────────────────────────
  /// Visible hairline on white surfaces
  static const Color borderLight = Color(0xFFD8D0C5);

  /// Medium border for emphasis
  static const Color borderMedium = Color(0xFFC0B5A8);
  static const Color borderDark = Color(0xFF8A8480);
  static const Color borderAccent = slateBlue;

  // ─── Semantic ─────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF3D8B65); // richer green
  static const Color info = slateBlue;
  static const Color warning = Color(0xFFCA8A3E); // warm amber
  static const Color error = Color(0xFFB04040); // muted red

  static const Color confidenceHigh = success;
  static const Color confidenceMedium = warning;
  static const Color confidenceLow = error;

  // ─── Glass / overlay ──────────────────────────────────────────────────────
  static const Color glassLight = Color(0xCCFFFFFF);
  static const Color glassBorder = Color(0x50C9BBAC);
  static const Color glassOverlay = Color(0x0AFFFFFF);

  // ─── Shadows ──────────────────────────────────────────────────────────────
  static const Color shadowWarm = Color(0x181C1A18);
  static const Color shadowSlate = Color(0x147B91AD);
  static const Color shadow = Color(0x0A000000);

  // ─── Splash ───────────────────────────────────────────────────────────────
  static const Color splashOrange = Color(0xFFFF6719);
  static const Color splashWhite = Color(0xFFFFFBF5);
  static const Color splashDune = Color(0xFF1C1A18);

  // ─── Gray scale ───────────────────────────────────────────────────────────
  static const Color gray100 = Color(0xFFEDE8E2);
  static const Color gray200 = Color(0xFFD6CFC5);
  static const Color gray300 = Color(0xFFBFB7AC);
  static const Color gray400 = Color(0xFFA8A09A);

  // =========================================================================
  // DARK MODE — Midnight Slate
  //
  // Built on the brand's COOL BLUE side, not warm brown.
  // Deep navy-slate canvas + taupe as a warm accent = premium, not muddy.
  // =========================================================================

  /// Deepest canvas — midnight slate-blue
  static const Color darkCanvas = Color(0xFF0D1520);

  /// Card / list item background
  static const Color darkSurface = Color(0xFF131E2F);

  /// Sidebar, drawers, elevated panels
  static const Color darkElevated = Color(0xFF192638);

  /// Bottom sheets, dialogs, modals
  static const Color darkModal = Color(0xFF1F3047);

  // Backwards-compat aliases
  static const Color darkBackgroundPrimary = darkCanvas;
  static const Color darkBackgroundSurface = darkSurface;
  static const Color darkBackgroundElevated = darkElevated;

  // ── Dark primary — luminous slate-blue pops on midnight background ─────────
  /// Primary interactive color in dark mode
  static const Color darkPrimary = Color(0xFF9BBBD8); // clear sky-slate
  /// Text/icon ON a darkPrimary surface
  static const Color darkOnPrimary = Color(0xFF0D1520);

  /// Container bg for chips, tags, selected states
  static const Color darkPrimaryContainer = Color(0xFF1D3550);

  // ── Dark taupe — warm accent on cool background ───────────────────────────
  /// Taupe remains warm but pops beautifully against the slate canvas
  static const Color darkTaupe = Color(0xFFCEBFB0);

  // ── Dark text ─────────────────────────────────────────────────────────────
  /// Primary text — cool white with slight blue tint
  static const Color darkTextPrimary = Color(0xFFEEF2F7);

  /// Secondary text — muted slate
  static const Color darkTextSecondary = Color(0xFFA0B0C4);

  /// Tertiary text — dim slate
  static const Color darkTextTertiary = Color(0xFF607080);

  // ── Dark borders — slate-blue tinted ──────────────────────────────────────
  /// Standard border (22% opacity slate-blue tint)
  static const Color darkBorder = Color(0x389BBBD8);

  /// Ultra-subtle separator (10% opacity)
  static const Color darkBorderSubtle = Color(0x189BBBD8);
}
