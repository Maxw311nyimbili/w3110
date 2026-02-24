import 'package:flutter/material.dart';
import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';
import 'package:cap_project/core/theme/app_spacing.dart';
import 'package:cap_project/app/view/app_router.dart';
import 'package:cap_project/core/widgets/widgets.dart';

enum SelectedFeature { chat, forum, scanner }

// Brand color shared with splash page for full consistency
const _kBrand = AppColors.brandDarkTeal; // #0C4B4F

class FeatureChoicePage extends StatefulWidget {
  const FeatureChoicePage({super.key});

  @override
  State<FeatureChoicePage> createState() => _FeatureChoicePageState();
}

class _FeatureChoicePageState extends State<FeatureChoicePage>
    with SingleTickerProviderStateMixin {
  SelectedFeature? _selectedFeature;
  late AnimationController _entryController;

  static const _features = [
    _FeatureDef(
      feature: SelectedFeature.chat,
      title: 'Clinical Support',
      subtitle: 'AI diagnostics, tailored health guidance, and expert advice.',
      icon: Icons.chat_bubble_outline_rounded,
      tag: 'AI · HEALTH',
    ),
    _FeatureDef(
      feature: SelectedFeature.forum,
      title: 'Peer Network',
      subtitle: 'Connect with communities and share lived experiences.',
      icon: Icons.people_outline_rounded,
      tag: 'COMMUNITY',
    ),
    _FeatureDef(
      feature: SelectedFeature.scanner,
      title: 'Rapid Validation',
      subtitle: 'Scan and verify prescriptions with medical-grade precision.',
      icon: Icons.document_scanner_outlined,
      tag: 'SCANNER',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Faint watermark
          Positioned(
            right: -100,
            top: -40,
            child: Opacity(
              opacity: 0.04,
              child: Transform.rotate(
                angle: -0.35,
                child: const BrandLogo(size: 520, isBreathing: false),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 32, 24, 24 + bottomPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──────────────────────────────────────────────
                  _FadeSlideIn(
                    controller: _entryController,
                    delay: 0.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusFull,
                            ),
                          ),
                          child: Text(
                            'SELECT INTENT',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              letterSpacing: 2.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'What are we\nfocusing on today?',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Choose one to get started.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Cards (flex to fill remaining space) ────────────────
                  Expanded(
                    child: Column(
                      children: _features.asMap().entries.map((entry) {
                        final i = entry.key;
                        final def = entry.value;
                        return Expanded(
                          child: _FadeSlideIn(
                            controller: _entryController,
                            delay: 0.15 + i * 0.12,
                            child: Padding(
                              padding: EdgeInsets.only(
                                bottom: i < _features.length - 1 ? 12 : 0,
                              ),
                              child: _FeatureCard(
                                def: def,
                                isSelected: _selectedFeature == def.feature,
                                onTap: () => setState(
                                  () => _selectedFeature = def.feature,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── CTA ─────────────────────────────────────────────────
                  _FadeSlideIn(
                    controller: _entryController,
                    delay: 0.55,
                    child: Center(
                      child: AppButton(
                        text: 'Continue',
                        width: 220,
                        borderRadius: AppSpacing.radiusFull,
                        backgroundColor: _selectedFeature != null
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).dividerColor.withOpacity(0.1),
                        foregroundColor: _selectedFeature != null
                            ? Colors.white
                            : Theme.of(context).textTheme.labelSmall?.color,
                        onPressed: _selectedFeature != null
                            ? () => _navigateToFeature(context)
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToFeature(BuildContext context) {
    if (_selectedFeature == null) return;
    switch (_selectedFeature!) {
      case SelectedFeature.chat:
        AppRouter.navigateTo<void>(context, AppRouter.chat);
      case SelectedFeature.forum:
        AppRouter.navigateTo<void>(context, AppRouter.forum);
      case SelectedFeature.scanner:
        AppRouter.navigateTo<void>(context, AppRouter.scanner);
    }
  }
}

// ─── Data model ──────────────────────────────────────────────────────────────

class _FeatureDef {
  const _FeatureDef({
    required this.feature,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tag,
  });
  final SelectedFeature feature;
  final String title;
  final String subtitle;
  final IconData icon;
  final String tag;
}

// ─── Feature card ────────────────────────────────────────────────────────────

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.def,
    required this.isSelected,
    required this.onTap,
  });

  final _FeatureDef def;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.06)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor.withOpacity(0.1),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _kBrand.withOpacity(0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: AppColors.shadowWarm,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            // Icon block
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(
                def.icon,
                color: isSelected ? Colors.white : Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),

            const SizedBox(width: 16),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          def.title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                              : Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusFull,
                          ),
                        ),
                        child: Text(
                          def.tag,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).textTheme.bodySmall?.color,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    def.subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor.withOpacity(0.1),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: isSelected ? Colors.white : Theme.of(context).colorScheme.primary,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Staggered fade+slide entry ──────────────────────────────────────────────

class _FadeSlideIn extends StatelessWidget {
  const _FadeSlideIn({
    required this.controller,
    required this.delay,
    required this.child,
  });

  final AnimationController controller;
  final double delay;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final start = delay.clamp(0.0, 0.9);
    final end = (delay + 0.35).clamp(0.0, 1.0);

    final opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );
    final slide =
        Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(start, end, curve: Curves.easeOutCubic),
          ),
        );

    return FadeTransition(
      opacity: opacity,
      child: SlideTransition(position: slide, child: child),
    );
  }
}
