// lib/core/theme/app_shadows.dart
// Hope UI Inspired — Teal-tinted, warm shadow system

import 'package:flutter/material.dart';

/// Surgical shadow system — color-tinted, never generic grey.
/// Use sparingly: only on elements that need to visually lift off the page.
class AppShadows {
  AppShadows._();

  /// Subtle ambient shadow for cards resting on the background
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x1A0C7E8A), // teal-tinted, 10% opacity
      blurRadius: 24,
      spreadRadius: -2,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x0F1C1917), // warm-black ambient, 6% opacity
      blurRadius: 12,
      spreadRadius: 0,
      offset: Offset(0, 2),
    ),
  ];

  /// Stronger shadow for modals, bottom sheets, and floating elements
  static const List<BoxShadow> float = [
    BoxShadow(
      color: Color(0x200C7E8A), // teal, 12% opacity
      blurRadius: 32,
      spreadRadius: 0,
      offset: Offset(0, 12),
    ),
    BoxShadow(
      color: Color(0x141C1917), // warm-black, 8% opacity
      blurRadius: 16,
      spreadRadius: 0,
      offset: Offset(0, 4),
    ),
  ];

  /// Very light shadow for inputs, chips, and inline elements
  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Color(0x0A1C1917), // warm-black, 4% opacity
      blurRadius: 6,
      spreadRadius: 0,
      offset: Offset(0, 2),
    ),
  ];

  /// Teal glow effect for active/focused interactive elements
  static const List<BoxShadow> tealGlow = [
    BoxShadow(
      color: Color(0x330C7E8A), // teal, 20% opacity
      blurRadius: 20,
      spreadRadius: -2,
      offset: Offset(0, 6),
    ),
  ];
}
