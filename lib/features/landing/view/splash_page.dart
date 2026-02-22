import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_spacing.dart';
import 'package:cap_project/core/widgets/glass_card.dart';
import 'package:cap_project/core/widgets/widgets.dart';
import 'package:cap_project/features/auth/cubit/auth_cubit.dart';
import 'package:cap_project/features/auth/cubit/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cap_project/app/view/app_router.dart';
import 'dart:math' as math;

/// Thanzi Premium SplashPage
/// Features: blur-to-sharp logo entry, rotation preserved, teal glow pulse,
/// typewriter tagline, glass card CTA reveal, status bar sync.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  // Main sequence controller (5s)
  late AnimationController _controller;

  // ─── Main sequence animations ───────────────────────────────────────────────
  late Animation<double> _logoX;
  late Animation<double> _logoRotation;
  late Animation<double> _logoBlur;     // 12 → 0 (blur-to-sharp on entry)
  late Animation<double> _logoY;
  late Animation<Color?> _logoColor;
  late Animation<double> _curtainReveal;
  late Animation<double> _contentOpacity;
  late Animation<Offset> _cardSlide;

  @override
  void initState() {
    super.initState();

    // Main 5s sequence
    _controller = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    );

    // 1. Logo entry — slides in from right + rotation (0.0s–2.0s)
    _logoX = Tween<double>(begin: 1.5, end: 0.52).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.40, curve: Curves.easeOutCubic),
      ),
    );

    _logoRotation = Tween<double>(begin: 0, end: 4 * math.pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.40, curve: Curves.easeOutQuart),
      ),
    );

    // Blur-to-sharp: synced with entry slide
    _logoBlur = Tween<double>(begin: 12.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.40, curve: Curves.easeOutCubic),
      ),
    );

    // 2. Inverted curtain reveal (2.25s–4.25s)
    _curtainReveal = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 0.85, curve: Curves.easeInOutQuart),
      ),
    );

    // 3. Logo shift & color morph (2.5s–4.5s)
    _logoY = Tween<double>(begin: 0.5, end: 0.28).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.50, 0.90, curve: Curves.easeInOutCubic),
      ),
    );

    _logoColor = ColorTween(
      begin: AppColors.brandDarkTeal,
      end: Colors.white,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 0.85, curve: Curves.linear),
      ),
    );

    // 4. Content reveal (4.1s–5.0s)
    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.82, 1.0, curve: Curves.easeIn),
      ),
    );

    // Glass card slides up from below screen (slightly ahead of content)
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.80, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Status bar sync: light icons on teal, dark icons when white curtain fills
    _curtainReveal.addListener(_syncStatusBar);

    _controller.forward();
  }

  void _syncStatusBar() {
    final isDarkBackground = _curtainReveal.value > 0.5;
    SystemChrome.setSystemUIOverlayStyle(
      isDarkBackground ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );
  }

  @override
  void dispose() {
    _curtainReveal.removeListener(_syncStatusBar);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final screenWidth = MediaQuery.of(context).size.width;

    return AndroidOptimized(
      child: Scaffold(
        backgroundColor: AppColors.brandDarkTeal,
        body: Stack(
          children: [
            // ── Morphing white curtain ─────────────────────────────────────
            AnimatedBuilder(
              animation: _curtainReveal,
              builder: (context, child) {
                return Positioned.fill(
                  child: CustomPaint(
                    painter: _InvertedCurtainPainter(
                      reveal: _curtainReveal.value,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),

            // ── Animated sequence ──────────────────────────────────────────
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, authState) {
                final isAuthenticated = authState.isAuthenticated;
                final tagline = isAuthenticated
                    ? 'SESSION RESTORED: ENCRYPTED PORTAL ACTIVE.\nWELCOME BACK, ${authState.user?.displayName?.toUpperCase() ?? "USER"}.'
                    : 'PRECISE TECHNICAL INFRASTRUCTURE\nFOR MODERN MATERNAL HEALTH.';

                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Stack(
                      children: [
                        // ── Logo: rotation + slide-in + blur-to-sharp ─────
                        Align(
                          alignment: FractionalOffset(0.52, _logoY.value),
                          child: ImageFiltered(
                            imageFilter: ImageFilter.blur(
                              sigmaX: _logoBlur.value,
                              sigmaY: _logoBlur.value,
                            ),
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                _logoColor.value ?? AppColors.brandDarkTeal,
                                BlendMode.srcIn,
                              ),
                              child: Transform.rotate(
                                angle: _logoRotation.value,
                                child: Opacity(
                                  opacity: _controller.value < 0.05 ? 0 : 1,
                                  child: Transform.translate(
                                    offset: Offset(
                                      screenWidth * (_logoX.value - 0.52),
                                      0,
                                    ),
                                    child: Image.asset(
                                      'assets/images/logo.png',
                                      width: 240,
                                      height: 240,
                                      fit: BoxFit.contain,
                                      errorBuilder: (ctx, err, st) =>
                                          const Icon(Icons.emergency_rounded,
                                              size: 120),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // ── Glass card: typewriter text + CTA ─────────────
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: SlideTransition(
                            position: _cardSlide,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                  20, 0, 20, 32 + bottomPadding),
                              child: GlassCard(
                                padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                                borderRadius: 28,
                                tintOpacity: 0.88,
                                blur: 16,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Typewriter tagline
                                    _TypewriterText(
                                      text: tagline,
                                      progress: _contentOpacity.value,
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.8,
                                        height: 1.8,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    AppButton(
                                      text: isAuthenticated
                                          ? 'Resume Session'
                                          : 'Get Started',
                                      width: 220,
                                      borderRadius: AppSpacing.radiusFull,
                                      backgroundColor: AppColors.brandDarkTeal,
                                      foregroundColor: Colors.white,
                                      onPressed: () {
                                        if (isAuthenticated) {
                                          AppRouter.replaceTo(context,
                                              AppRouter.featureChoice);
                                        } else {
                                          AppRouter.navigateTo(context,
                                              AppRouter.featureChoice);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Reveals characters from left to right based on [progress] (0.0–1.0).
class _TypewriterText extends StatelessWidget {
  const _TypewriterText({
    required this.text,
    required this.progress,
    required this.style,
  });

  final String text;
  final double progress;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final visible = (text.length * progress).round().clamp(0, text.length);
    return Text(
      text.substring(0, visible),
      textAlign: TextAlign.center,
      style: style,
    );
  }
}

class _InvertedCurtainPainter extends CustomPainter {
  final double reveal;
  final Color color;

  _InvertedCurtainPainter({required this.reveal, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final currentTopY = (size.height * 0.83) * (1.0 - reveal);
    final currentCurveDepth = (size.height * 0.17) * (1.0 - reveal);

    path.moveTo(0, size.height);
    path.lineTo(0, currentTopY);
    path.quadraticBezierTo(
      size.width / 2, currentTopY - currentCurveDepth,
      size.width, currentTopY,
    );
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _InvertedCurtainPainter oldDelegate) =>
      reveal != oldDelegate.reveal || color != oldDelegate.color;
}
