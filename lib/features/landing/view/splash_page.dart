// lib/features/landing/view/splash_page.dart
//
// Naiia Premium Splash — "Living Mark" reveal.
//
// Sequence (3.6s total):
//   0.00–0.70s  Warm glow blooms from centre + mark scales 0.76→1.0 + fades in
//   0.50–1.10s  Mark begins breathing (isBreathing = true)
//   0.70–1.30s  "naiia" wordmark slides up 12px + fades in
//   1.10–1.60s  Tagline fades in, letter-spaced
//   2.20–3.00s  CTA button springs in from below
//   (Auth auto-routes when resolved)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:landing_repository/landing_repository.dart';

import 'package:cap_project/app/view/app_router.dart';
import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_spacing.dart';
import 'package:cap_project/core/widgets/brand_logo.dart';
import 'package:cap_project/core/widgets/widgets.dart';
import 'package:cap_project/features/auth/cubit/auth_cubit.dart';
import 'package:cap_project/features/auth/cubit/auth_state.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _seq;

  // Phase 1 — mark entry (0→0.70s / interval 0.0–0.194)
  late Animation<double> _markScale;
  late Animation<double> _markOpacity;

  // Phase 2 — warm glow behind mark (0→0.70s / interval 0.0–0.194)
  late Animation<double> _glowOpacity;
  late Animation<double> _glowScale;

  // Phase 3 — wordmark slide-up (0.70→1.30s / interval 0.194–0.361)
  late Animation<double> _nameOpacity;
  late Animation<Offset> _nameSlide;

  // Phase 4 — tagline fade (1.10→1.70s / interval 0.305–0.472)
  late Animation<double> _taglineOpacity;

  // Phase 5 — CTA spring (2.20→3.00s / interval 0.611–0.833)
  late Animation<double> _ctaScale;
  late Animation<double> _ctaOpacity;

  // Whether breathing should be active on the logo
  bool _isBreathing = false;

  @override
  void initState() {
    super.initState();

    _seq = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    );

    // ── Mark entry ──────────────────────────────────────────────────────────
    _markScale = Tween<double>(begin: 0.76, end: 1.0).animate(
      CurvedAnimation(
        parent: _seq,
        curve: const Interval(0.0, 0.194, curve: Curves.easeOutCubic),
      ),
    );
    _markOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _seq,
        curve: const Interval(0.0, 0.139, curve: Curves.easeOut),
      ),
    );

    // ── Warm glow ───────────────────────────────────────────────────────────
    _glowOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 30),
      TweenSequenceItem(tween: ConstantTween(1.0),           weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(
      CurvedAnimation(
        parent: _seq,
        curve: const Interval(0.0, 0.80, curve: Curves.easeInOut),
      ),
    );
    _glowScale = Tween<double>(begin: 0.6, end: 1.8).animate(
      CurvedAnimation(
        parent: _seq,
        curve: const Interval(0.0, 0.60, curve: Curves.easeOut),
      ),
    );

    // ── Wordmark ────────────────────────────────────────────────────────────
    _nameOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _seq,
        curve: const Interval(0.194, 0.333, curve: Curves.easeOut),
      ),
    );
    _nameSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _seq,
        curve: const Interval(0.194, 0.361, curve: Curves.easeOutCubic),
      ),
    );

    // ── Tagline ─────────────────────────────────────────────────────────────
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _seq,
        curve: const Interval(0.305, 0.472, curve: Curves.easeOut),
      ),
    );

    // ── CTA button ──────────────────────────────────────────────────────────
    _ctaScale = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _seq,
        curve: const Interval(0.611, 0.833, curve: Curves.easeOutBack),
      ),
    );
    _ctaOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _seq,
        curve: const Interval(0.611, 0.722, curve: Curves.easeOut),
      ),
    );

    // Trigger breathing at t ≈ 0.50s (interval 0.139)
    _seq.addListener(() {
      if (_seq.value > 0.139 && !_isBreathing) {
        setState(() => _isBreathing = true);
      }
    });

    _handleEntry();
  }

  Future<void> _handleEntry() async {
    // Set status bar
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ));

    try {
      final landingRepo = context.read<LandingRepository>();
      final lastSplash = await landingRepo.getLastSplashTime();
      final now = DateTime.now();

      if (lastSplash != null && now.difference(lastSplash).inHours < 2) {
        // Skip animation — seen recently
        _seq.value = 1.0;
        setState(() => _isBreathing = true);
      } else {
        _seq.forward();
        await landingRepo.saveLastSplashTime(now);
      }
    } catch (_) {
      _seq.forward();
    }
  }

  @override
  void dispose() {
    _seq.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? AppColors.darkCanvas : AppColors.warmIvory;
    final inkColor = isDark ? AppColors.darkTextPrimary : AppColors.ink;
    final taglineColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final glowColor = isDark
        ? const Color(0xFF1A2430) // deep navy glow in dark
        : const Color(0xFFE8EDF3); // soft slate-blue tint in light

    return AndroidOptimized(
      child: Scaffold(
        backgroundColor: bgColor,
        body: BlocListener<AuthCubit, AuthState>(
          listenWhen: (prev, curr) => prev.status != curr.status,
          listener: (context, state) {
            // Auto-route once auth resolves (after animation or immediately)
            if (state.status == AuthStatus.authenticated) {
              Future.delayed(const Duration(milliseconds: 200), () {
                if (mounted) AppRouter.replaceTo(context, AppRouter.shell);
              });
            }
          },
          child: AnimatedBuilder(
            animation: _seq,
            builder: (context, _) {
              return BlocBuilder<AuthCubit, AuthState>(
                builder: (context, authState) {
                  final isAuthenticated =
                      authState.status == AuthStatus.authenticated;
                  final tagline = isAuthenticated
                      ? 'Welcome back'
                      : 'Together. We parent.';

                  return Stack(
                    children: [
                      // ── Warm radial glow behind mark ─────────────────────
                      Positioned.fill(
                        child: Center(
                          child: Opacity(
                            opacity: _glowOpacity.value.clamp(0.0, 1.0),
                            child: Transform.scale(
                              scale: _glowScale.value,
                              child: Container(
                                width: size.width * 0.75,
                                height: size.width * 0.75,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      glowColor.withOpacity(0.85),
                                      glowColor.withOpacity(0.0),
                                    ],
                                    stops: const [0.0, 1.0],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ── Main content column ──────────────────────────────
                      Positioned.fill(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(flex: 3),

                            // ── Brand mark ──────────────────────────────────
                            Transform.scale(
                              scale: _markScale.value,
                              child: Opacity(
                                opacity: _markOpacity.value.clamp(0.0, 1.0),
                                child: BrandLogo(
                                  size: 140,
                                  isBreathing: _isBreathing,
                                ),
                              ),
                            ),

                            const SizedBox(height: 28),

                            // ── "NAIIA" display wordmark ──────────────────────
                            ClipRect(
                              child: SlideTransition(
                                position: _nameSlide,
                                child: FadeTransition(
                                  opacity: _nameOpacity,
                                  child: Text(
                                    'NAIIA',
                                    style: GoogleFonts.cormorantGaramond(
                                      fontSize: 52,
                                      fontWeight: FontWeight.w300,
                                      color: AppColors.slateBlue,
                                      letterSpacing: 8,
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // ── Tagline ──────────────────────────────────────
                            FadeTransition(
                              opacity: _taglineOpacity,
                              child: Text(
                                tagline,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.cormorantGaramond(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.italic,
                                  letterSpacing: 0.5,
                                  color: taglineColor,
                                ),
                              ),
                            ),

                            const Spacer(flex: 3),

                            // ── CTA button ───────────────────────────────────
                            Opacity(
                              opacity: _ctaOpacity.value.clamp(0.0, 1.0),
                              child: Transform.scale(
                                scale: _ctaScale.value,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    bottom: 40 + bottomPad,
                                  ),
                                  child: _SplashButton(
                                    label: isAuthenticated
                                        ? 'Resume Session'
                                        : 'Get Started',
                                    onTap: () {
                                      if (isAuthenticated) {
                                        AppRouter.replaceTo(
                                            context, AppRouter.shell);
                                      } else {
                                        AppRouter.navigateTo(
                                            context, AppRouter.landing);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

// ── Premium CTA button with warm shadow ────────────────────────────────────────

class _SplashButton extends StatefulWidget {
  const _SplashButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  State<_SplashButton> createState() => _SplashButtonState();
}

class _SplashButtonState extends State<_SplashButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _press, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkPrimary : AppColors.slateBlue;
    final fg = isDark ? AppColors.darkOnPrimary : Colors.white;

    return GestureDetector(
      onTapDown: (_) => _press.forward(),
      onTapUp: (_) {
        _press.reverse();
        widget.onTap();
      },
      onTapCancel: () => _press.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          constraints: const BoxConstraints(minWidth: 200),
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            boxShadow: [
              BoxShadow(
                color: bg.withOpacity(0.30),
                blurRadius: 24,
                spreadRadius: -4,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: fg,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}
