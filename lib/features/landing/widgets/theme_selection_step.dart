// lib/features/landing/widgets/theme_selection_step.dart
//
// First-time theme picker — shown once during onboarding (between consent
// and complete). Lets the user choose Light or Dark mode with a live preview.
// The choice is persisted by ThemeCubit so it never shows again.

import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';
import 'package:cap_project/core/theme/cubit/theme_cubit.dart';
import 'package:cap_project/core/theme/cubit/theme_state.dart';
import 'package:cap_project/core/widgets/premium_button.dart';
import 'package:cap_project/features/landing/cubit/cubit.dart';
import 'package:cap_project/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeSelectionStep extends StatefulWidget {
  const ThemeSelectionStep({super.key});

  @override
  State<ThemeSelectionStep> createState() => _ThemeSelectionStepState();
}

class _ThemeSelectionStepState extends State<ThemeSelectionStep> {
  // Start with whatever the current system preference is
  AppThemeMode _selected = AppThemeMode.system;

  @override
  void initState() {
    super.initState();
    // Mirror whatever ThemeCubit currently has
    _selected = context.read<ThemeCubit>().state.themeMode;
    // Default to light if system (give them a concrete starting point)
    if (_selected == AppThemeMode.system) _selected = AppThemeMode.light;
  }

  void _pick(AppThemeMode mode) {
    setState(() => _selected = mode);
    // Live preview — applies immediately
    context.read<ThemeCubit>().setThemeMode(mode);
  }

  void _continue() {
    context.read<LandingCubit>().completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: Theme.of(context).textTheme.bodyLarge?.color,
          onPressed: () => context.read<LandingCubit>().previousStep(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────────────
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                builder: (ctx, v, _) => Opacity(
                  opacity: v,
                  child: Transform.translate(
                    offset: Offset(0, 12 * (1 - v)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context).makeItYours,
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1.0,
                                fontSize: 34,
                                color: Theme.of(
                                  context,
                                ).textTheme.displayLarge?.color,
                              ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Choose how Naiia looks. You can always change this in settings.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // ── Theme cards ───────────────────────────────────────────────
              Expanded(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOut,
                  builder: (ctx, v, _) => Opacity(
                    opacity: v,
                    child: Transform.translate(
                      offset: Offset(0, 12 * (1 - v)),
                      child: Row(
                        children: [
                          Expanded(
                            child: _ThemeCard(
                              label: AppLocalizations.of(context).themeLight,
                              icon: Icons.wb_sunny_rounded,
                              mode: AppThemeMode.light,
                              selected: _selected == AppThemeMode.light,
                              onTap: () => _pick(AppThemeMode.light),
                              preview: const _LightPreview(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _ThemeCard(
                              label: AppLocalizations.of(context).themeDark,
                              icon: Icons.dark_mode_rounded,
                              mode: AppThemeMode.dark,
                              selected: _selected == AppThemeMode.dark,
                              onTap: () => _pick(AppThemeMode.dark),
                              preview: const _DarkPreview(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ── Continue button ───────────────────────────────────────────
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOut,
                builder: (ctx, v, _) => Opacity(
                  opacity: v,
                  child: PremiumButton(
                    onPressed: _continue,
                    text: AppLocalizations.of(context).startUsingNaiia,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual theme card
// ─────────────────────────────────────────────────────────────────────────────

class _ThemeCard extends StatefulWidget {
  const _ThemeCard({
    required this.label,
    required this.icon,
    required this.mode,
    required this.selected,
    required this.onTap,
    required this.preview,
  });

  final String label;
  final IconData icon;
  final AppThemeMode mode;
  final bool selected;
  final VoidCallback onTap;
  final Widget preview;

  @override
  State<_ThemeCard> createState() => _ThemeCardState();
}

class _ThemeCardState extends State<_ThemeCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final borderColor = widget.selected
        ? primary
        : (isDark ? AppColors.darkBorderSubtle : AppColors.borderLight);

    final bgColor = widget.selected
        ? primary.withOpacity(isDark ? 0.08 : 0.06)
        : (isDark ? AppColors.darkSurface : AppColors.backgroundSurface);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: borderColor,
              width: widget.selected ? 2 : 1,
            ),
            boxShadow: widget.selected
                ? [
                    BoxShadow(
                      color: primary.withOpacity(0.18),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(19),
            child: Column(
              children: [
                // ── Mini preview ─────────────────────────────────────────
                AspectRatio(
                  aspectRatio: 0.85,
                  child: widget.preview,
                ),

                // ── Label row ────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        widget.icon,
                        size: 18,
                        color: widget.selected
                            ? primary
                            : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.label,
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: widget.selected
                              ? primary
                              : (isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary),
                        ),
                      ),
                      const Spacer(),
                      if (widget.selected)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 13,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Light mode mini preview
// ─────────────────────────────────────────────────────────────────────────────

class _LightPreview extends StatelessWidget {
  const _LightPreview();

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF8F6EF); // warmIvory
    const surface = Color(0xFFFFFFFF); // white
    const sidebar = Color(0xFFEDE8E1); // subtle warm secondary
    const accent = Color(0xFF7B91AD); // slateBlue
    const textDark = Color(0xFF18181B);
    const textMid = Color(0xFF6E7278);

    return Container(
      color: bg,
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sidebar
          Container(
            width: 36,
            decoration: BoxDecoration(
              color: sidebar,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                _dot(accent, 22, 22),
                const SizedBox(height: 8),
                _dot(surface, 22, 8),
                _dot(surface, 22, 8),
                _dot(surface, 22, 8),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Chat area
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // User bubble
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _textLine(surface, 40, 5),
                  ),
                ),
                // AI bubble
                Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFD8D0C5),
                      width: 0.8,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _textLine(textDark, double.infinity, 5),
                      const SizedBox(height: 3),
                      _textLine(textMid, 50, 4),
                    ],
                  ),
                ),
                const Spacer(),
                // Input bar
                Container(
                  height: 22,
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFD8D0C5),
                      width: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _dot(Color color, double w, double h) => Container(
    width: w,
    height: h,
    margin: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(4),
    ),
  );

  static Widget _textLine(Color color, double w, double h) => Container(
    width: w,
    height: h,
    decoration: BoxDecoration(
      color: color.withOpacity(0.35),
      borderRadius: BorderRadius.circular(3),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Dark mode mini preview
// ─────────────────────────────────────────────────────────────────────────────

class _DarkPreview extends StatelessWidget {
  const _DarkPreview();

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0D1520); // darkCanvas
    const surface = Color(0xFF131E2F); // darkSurface
    const sidebar = Color(0xFF192638); // darkElevated
    const accent = Color(0xFF9BBBD8); // darkPrimary
    const textBright = Color(0xFFEEF2F7);
    const textDim = Color(0xFFA0B0C4);

    return Container(
      color: bg,
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sidebar
          Container(
            width: 36,
            decoration: BoxDecoration(
              color: sidebar,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                _dot(accent, 22, 22),
                const SizedBox(height: 8),
                _dot(surface, 22, 8),
                _dot(surface, 22, 8),
                _dot(surface, 22, 8),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Chat area
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // User bubble
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: accent.withOpacity(0.35),
                        width: 0.8,
                      ),
                    ),
                    child: _textLine(accent, 40, 5),
                  ),
                ),
                // AI bubble
                Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: accent.withOpacity(0.15),
                      width: 0.8,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _textLine(textBright, double.infinity, 5),
                      const SizedBox(height: 3),
                      _textLine(textDim, 50, 4),
                    ],
                  ),
                ),
                const Spacer(),
                // Input bar
                Container(
                  height: 22,
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: accent.withOpacity(0.18),
                      width: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _dot(Color color, double w, double h) => Container(
    width: w,
    height: h,
    margin: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(4),
    ),
  );

  static Widget _textLine(Color color, double w, double h) => Container(
    width: w,
    height: h,
    decoration: BoxDecoration(
      color: color.withOpacity(0.40),
      borderRadius: BorderRadius.circular(3),
    ),
  );
}
