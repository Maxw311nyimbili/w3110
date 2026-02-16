import 'package:flutter/material.dart';
import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';
import 'package:cap_project/features/auth/cubit/auth_cubit.dart';
import 'package:cap_project/features/auth/cubit/auth_state.dart';
import 'package:cap_project/core/widgets/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cap_project/app/view/app_router.dart';
import 'dart:math' as math;

/// Thanzi Dynamic SplashPage - Inverted Curtain Reveal with Technical Typography
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  // Animation factors
  late Animation<double> _logoX;
  late Animation<double> _logoRotation;
  late Animation<double> _logoY;
  late Animation<Color?> _logoColor;
  late Animation<double> _curtainReveal; // 1.0 (full screen white) to 0.0 (bottom semi-circle)
  late Animation<double> _contentOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    );

    // 1. Logo Entry & Sophisticated Rotation (0.0s - 1.8s)
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

    // 2. The "Inverted Curtain Reveal" (2.0s - 3.8s)
    _curtainReveal = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 0.85, curve: Curves.easeInOutQuart),
      ),
    );

    // 3. Logo Shift & Color Morph (2.0s - 3.8s)
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

    // 4. Content Reveal (3.8s - 5.0s)
    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.85, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return AndroidOptimized(
      child: Scaffold(
        backgroundColor: AppColors.brandDarkTeal,
        body: Stack(
          children: [
            // The Morphing White Curtain
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

            // Animated Sequence
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, authState) {
                final isAuthenticated = authState.isAuthenticated;
                
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Stack(
                      children: [
                        // The Rotating & Color-Shifting Logo
                        Align(
                          alignment: FractionalOffset(0.52, _logoY.value),
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
                                  offset: Offset((MediaQuery.of(context).size.width * (_logoX.value - 0.52)) , 0),
                                  child: Image.asset(
                                    'assets/images/logo.png',
                                    width: 240, 
                                    height: 240,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) => 
                                        const Icon(Icons.emergency_rounded, size: 120),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
    
                        // Compact Technical Text (Middle Section)
                        Align(
                          alignment: const FractionalOffset(0.5, 0.58), // Perfectly between logo and button
                          child: Opacity(
                            opacity: _contentOpacity.value,
                            child: Text(
                              isAuthenticated 
                                ? 'SESSION RESTORED: ENCRYPTED PORTAL ACTIVE.\nWELCOME BACK, ${authState.user?.displayName?.toUpperCase() ?? "USER"}.'
                                : 'PRECISE TECHNICAL INFRASTRUCTURE\nFOR MODERN MATERNAL HEALTH.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.8,
                                height: 1.8,
                              ),
                            ),
                          ),
                        ),
    
                        // "GETTING STARTED" Button
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 60 + bottomPadding),
                            child: Opacity(
                              opacity: _contentOpacity.value,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 280),
                                child: AppButton(
                                  text: isAuthenticated ? 'RESUME SESSION' : 'GETTING STARTED',
                                  backgroundColor: AppColors.brandDarkTeal,
                                  foregroundColor: Colors.white,
                                  onPressed: () {
                                    if (isAuthenticated) {
                                      // Go directly to feature choice/dashboard
                                      AppRouter.replaceTo(context, AppRouter.featureChoice);
                                    } else {
                                      AppRouter.navigateTo(context, AppRouter.featureChoice);
                                    }
                                  },
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
