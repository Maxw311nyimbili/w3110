// lib/features/rating/rating_dialog.dart
//
// Premium 5-star rating dialog — light & dark mode aware.

import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_spacing.dart';
import 'package:cap_project/features/rating/rating_cubit.dart';

/// Shows the rating bottom-sheet. Call this from AppShell when
/// [RatingStatus.showing] is emitted.
Future<void> showRatingDialog(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: context.read<RatingCubit>(),
      child: const _RatingSheet(),
    ),
  );
}

class _RatingSheet extends StatefulWidget {
  const _RatingSheet();

  @override
  State<_RatingSheet> createState() => _RatingSheetState();
}

class _RatingSheetState extends State<_RatingSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final surfaceColor = isDark
        ? AppColors.darkBackgroundSurface
        : AppColors.backgroundSurface;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;
    final borderColor = isDark
        ? AppColors.darkBorder.withOpacity(0.3)
        : AppColors.borderLight;

    return ScaleTransition(
      scale: _scaleAnim,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.4)
                  : AppColors.shadowTeal.withOpacity(0.12),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: BlocConsumer<RatingCubit, RatingState>(
          listener: (context, state) {
            if (state.status == RatingStatus.submitted ||
                state.status == RatingStatus.dismissed) {
              Navigator.of(context).pop();
            }
          },
          builder: (context, state) {
            if (state.status == RatingStatus.submitted) {
              return _ThankYouView(isDark: isDark, textPrimary: textPrimary);
            }
            return _RatingFormView(
              state: state,
              isDark: isDark,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              commentController: _commentController,
              onStarTap: (s) => context.read<RatingCubit>().selectStars(s),
              onCommentChanged: (v) => context.read<RatingCubit>().updateComment(v),
              onSubmit: () => context.read<RatingCubit>().submit(
                platform: _platformString(),
              ),
              onDismiss: () => context.read<RatingCubit>().dismiss(),
            );
          },
        ),
      ),
    );
  }

  String _platformString() {
    try {
      if (Platform.isAndroid) return 'android';
      if (Platform.isIOS) return 'ios';
    } catch (_) {}
    return 'web';
  }
}

// ── Rating form ───────────────────────────────────────────────────────────────

class _RatingFormView extends StatelessWidget {
  const _RatingFormView({
    required this.state,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.commentController,
    required this.onStarTap,
    required this.onCommentChanged,
    required this.onSubmit,
    required this.onDismiss,
  });

  final RatingState state;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  final TextEditingController commentController;
  final void Function(int) onStarTap;
  final void Function(String) onCommentChanged;
  final VoidCallback onSubmit;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final isSubmitting = state.status == RatingStatus.submitting;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.xl,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle bar ──
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.15)
                  : Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── Headline ──
          Text(
            'Enjoying Naiia?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your feedback helps us improve. It only takes a second.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: textSecondary, height: 1.4),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // ── Star row ──
          _StarRow(
            selected: state.selectedStars,
            onTap: onStarTap,
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── Comment field (shown after star selected) ──
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: state.selectedStars > 0
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Column(
              children: [
                TextField(
                  controller: commentController,
                  onChanged: onCommentChanged,
                  maxLines: 3,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText: 'Tell us more (optional)…',
                    counterStyle: TextStyle(color: textSecondary, fontSize: 11),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
            secondChild: const SizedBox.shrink(),
          ),

          // ── Submit button ──
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (state.selectedStars > 0 && !isSubmitting)
                  ? onSubmit
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                disabledBackgroundColor: AppColors.accentPrimary.withOpacity(0.4),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Submit Rating',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Maybe Later ──
          TextButton(
            onPressed: isSubmitting ? null : onDismiss,
            child: Text(
              'Maybe Later',
              style: TextStyle(color: textSecondary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Star row ──────────────────────────────────────────────────────────────────

class _StarRow extends StatefulWidget {
  const _StarRow({required this.selected, required this.onTap});
  final int selected;
  final void Function(int) onTap;

  @override
  State<_StarRow> createState() => _StarRowState();
}

class _StarRowState extends State<_StarRow> {
  int _hover = 0;

  @override
  Widget build(BuildContext context) {
    final effective = _hover > 0 ? _hover : widget.selected;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final idx = i + 1;
        final filled = idx <= effective;
        return GestureDetector(
          onTap: () => widget.onTap(idx),
          onPanUpdate: (d) {
            // Allow drag to rate
            final box = context.findRenderObject()! as RenderBox;
            final x = d.localPosition.dx;
            final w = box.size.width / 5;
            final star = ((x / w).ceil()).clamp(1, 5);
            setState(() => _hover = star);
          },
          onPanEnd: (_) {
            if (_hover > 0) widget.onTap(_hover);
            setState(() => _hover = 0);
          },
          child: MouseRegion(
            onEnter: (_) => setState(() => _hover = idx),
            onExit: (_) => setState(() => _hover = 0),
            child: AnimatedScale(
              scale: filled ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOutBack,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  filled ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 44,
                  color: filled
                      ? const Color(0xFFFFC107) // Amber star
                      : Colors.grey.withOpacity(0.4),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ── Thank-you view ────────────────────────────────────────────────────────────

class _ThankYouView extends StatelessWidget {
  const _ThankYouView({required this.isDark, required this.textPrimary});
  final bool isDark;
  final Color textPrimary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutBack,
            builder: (_, v, child) => Transform.scale(scale: v, child: child),
            child: const Icon(
              Icons.favorite_rounded,
              color: AppColors.accentPrimary,
              size: 56,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Thank you! 🎉',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your rating means a lot to us and helps us make Naiia better for everyone.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
