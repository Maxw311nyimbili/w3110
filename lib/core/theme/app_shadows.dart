// lib/core/theme/app_shadows.dart
// Naiia — Warm Slate-Blue shadow system
//
// Two-color layering principle:
//   1. A slate-blue ambient lift (gives brand-tinted depth)
//   2. A warm-black gravity shadow (grounds the element)
//
// Use sparingly — only on elements that need to visually separate from their bg.

import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  // ── Card: resting on background ─────────────────────────────────────────────
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0E7B91AD), // slate-blue, ~5% opacity
      blurRadius: 20,
      spreadRadius: -2,
      offset: Offset(0, 6),
    ),
    BoxShadow(
      color: Color(0x0A1C1917), // warm-black ambient, 4% opacity
      blurRadius: 8,
      spreadRadius: 0,
      offset: Offset(0, 2),
    ),
  ];

  // ── Float: modals, sheets, and elevated surfaces ────────────────────────────
  static const List<BoxShadow> float = [
    BoxShadow(
      color: Color(0x167B91AD), // slate-blue, ~9% opacity
      blurRadius: 40,
      spreadRadius: -4,
      offset: Offset(0, 16),
    ),
    BoxShadow(
      color: Color(0x121C1917), // warm-black, ~7% opacity
      blurRadius: 20,
      spreadRadius: 0,
      offset: Offset(0, 6),
    ),
    BoxShadow(
      color: Color(0x061C1917), // hair-thin contact shadow
      blurRadius: 4,
      spreadRadius: 0,
      offset: Offset(0, 1),
    ),
  ];

  // ── Subtle: inputs, chips, inline elements ──────────────────────────────────
  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Color(0x081C1917), // warm-black, 3% opacity
      blurRadius: 6,
      spreadRadius: 0,
      offset: Offset(0, 2),
    ),
  ];

  // ── Primary glow: focused inputs, active CTAs ───────────────────────────────
  static const List<BoxShadow> primaryGlow = [
    BoxShadow(
      color: Color(0x267B91AD), // slate-blue glow, ~15% opacity
      blurRadius: 24,
      spreadRadius: -2,
      offset: Offset(0, 8),
    ),
  ];

  // ── Button shadow ────────────────────────────────────────────────────────────
  static const List<BoxShadow> button = [
    BoxShadow(
      color: Color(0x307B91AD), // slate-blue, ~19% opacity
      blurRadius: 16,
      spreadRadius: -4,
      offset: Offset(0, 6),
    ),
    BoxShadow(
      color: Color(0x141C1917), // warm-black, 8% opacity
      blurRadius: 6,
      spreadRadius: 0,
      offset: Offset(0, 2),
    ),
  ];

  // ── Dark-mode card ───────────────────────────────────────────────────────────
  static const List<BoxShadow> cardDark = [
    BoxShadow(
      color: Color(0x40000000), // pure-black, 25% opacity
      blurRadius: 24,
      spreadRadius: -4,
      offset: Offset(0, 10),
    ),
    BoxShadow(
      color: Color(0x20000000), // pure-black, 12% opacity
      blurRadius: 8,
      spreadRadius: 0,
      offset: Offset(0, 2),
    ),
  ];

  // Keep legacy alias so old references compile
  static const List<BoxShadow> tealGlow = primaryGlow;
}
