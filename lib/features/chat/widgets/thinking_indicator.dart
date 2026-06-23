import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Naiia thinking indicator — two distinct phases:
///
/// **Phase 1 — HEARTBEAT** (AI is working):
///   The mark does a cardiac lub-dub double-pulse every 1.8 s.
///   Sparks are present but dim (opacity ≈ 0.32), flaring on each beat.
///
/// **Phase 2 — SPARK SEQUENCE** (response arriving):
///   Core holds a slow, calm breathe (3 s cycle, scale 1→1.015).
///   Four virtual sparks fire sequentially at 0 / 180 / 360 / 540 ms offsets,
///   each flashing 0.18 → 1.0 → 0.18 over a 1.5 s window — simulated via a
///   combined max-opacity waveform since the SVG sparks are one layer.
///
/// Triggered by calling [NaiiaThinkingController.signalNearResponse()].
class ThinkingIndicator extends StatefulWidget {
  const ThinkingIndicator({super.key, this.controller});

  final NaiiaThinkingController? controller;

  @override
  State<ThinkingIndicator> createState() => _ThinkingIndicatorState();
}

class NaiiaThinkingController extends ChangeNotifier {
  bool _nearResponse = false;
  bool get nearResponse => _nearResponse;

  void signalNearResponse() {
    if (!_nearResponse) {
      _nearResponse = true;
      notifyListeners();
    }
  }

  void reset() {
    _nearResponse = false;
    notifyListeners();
  }
}

class _ThinkingIndicatorState extends State<ThinkingIndicator>
    with TickerProviderStateMixin {
  // ── Phase 1: heartbeat (1.8 s cardiac lub-dub) ────────────────────────────
  late final AnimationController _heartC;
  late final Animation<double> _beatScale;
  late final Animation<double> _heartSparkOpacity;

  // ── Phase 2: spark sequence (3 s breathe + 1.5 s spark cycle) ─────────────
  late final AnimationController _breathC; // 3 s slow breathe for core
  late final Animation<double> _breathScale;

  late final AnimationController _sparkC; // 1.5 s cycle for sequential sparks
  // sparkC drives 4 virtual sparks at offsets 0, 0.12, 0.24, 0.36 of cycle

  // ── Cross-fade between phases ──────────────────────────────────────────────
  late final AnimationController _phaseC; // 0 = heartbeat, 1 = spark-seq
  late final Animation<double> _phaseAnim;

  // ── Word cycling ──────────────────────────────────────────────────────────
  final List<String> _words = [
    'thinking',
    'searching',
    'analyzing',
    'verifying',
  ];
  int _wordIndex = 0;
  late Timer _wordTimer;

  bool _nearResponse = false;

  @override
  void initState() {
    super.initState();

    // ── Heartbeat controller ─────────────────────────────────────────────────
    _heartC = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    // Cardiac lub-dub: beat at 8 % and 25 % of cycle, then 67 % rest.
    _beatScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.000, end: 1.075), weight: 8),
      TweenSequenceItem(tween: Tween(begin: 1.075, end: 1.000), weight: 9),
      TweenSequenceItem(tween: Tween(begin: 1.000, end: 1.045), weight: 8),
      TweenSequenceItem(tween: Tween(begin: 1.045, end: 1.000), weight: 8),
      TweenSequenceItem(tween: ConstantTween(1.000), weight: 67),
    ]).animate(CurvedAnimation(parent: _heartC, curve: Curves.easeInOut));

    // Sparks flare with the beats and return to resting dim.
    _heartSparkOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.32, end: 1.00), weight: 8),
      TweenSequenceItem(tween: Tween(begin: 1.00, end: 0.80), weight: 9),
      TweenSequenceItem(tween: Tween(begin: 0.80, end: 0.32), weight: 8),
      TweenSequenceItem(tween: ConstantTween(0.32), weight: 75),
    ]).animate(_heartC);

    // ── Breathe controller (phase 2 core) ───────────────────────────────────
    _breathC = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _breathScale = Tween<double>(
      begin: 1.000,
      end: 1.015,
    ).animate(CurvedAnimation(parent: _breathC, curve: Curves.easeInOut));

    // ── Spark-sequence controller ────────────────────────────────────────────
    _sparkC = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // ── Phase cross-fade ─────────────────────────────────────────────────────
    _phaseC = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _phaseAnim = CurvedAnimation(parent: _phaseC, curve: Curves.easeInOut);

    // ── Word cycling every 2 s ───────────────────────────────────────────────
    _wordTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted)
        setState(() => _wordIndex = (_wordIndex + 1) % _words.length);
    });

    widget.controller?.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (!mounted) return;
    final near = widget.controller?.nearResponse ?? false;
    setState(() => _nearResponse = near);
    if (near) {
      _phaseC.forward();
    } else {
      _phaseC.reverse();
    }
  }

  @override
  void dispose() {
    _heartC.dispose();
    _breathC.dispose();
    _sparkC.dispose();
    _phaseC.dispose();
    _wordTimer.cancel();
    widget.controller?.removeListener(_onControllerChanged);
    super.dispose();
  }

  /// Computes the combined opacity of 4 staggered virtual sparks.
  /// Each spark fires at offset i*0.12 of the 1.5 s cycle:
  ///   rise  0 → 0.18 of its window
  ///   peak  at 0.18
  ///   fall  0.18 → 0.45 of its window
  ///   rest  0.45 → 1.0
  double _seqSparkOpacity(double t) {
    const numSparks = 4;
    const offsets = [0.00, 0.12, 0.24, 0.36]; // fraction of cycle
    const riseFrac = 0.18;
    const peakFrac = 0.18;
    const fallFrac = 0.27;

    double maxOp = 0.18;
    for (int i = 0; i < numSparks; i++) {
      final local = (t - offsets[i] + 1.0) % 1.0;
      final double op;
      if (local < riseFrac) {
        op = 0.18 + (1.0 - 0.18) * (local / riseFrac);
      } else if (local < riseFrac + peakFrac) {
        op = 1.0;
      } else if (local < riseFrac + peakFrac + fallFrac) {
        final fallT = (local - riseFrac - peakFrac) / fallFrac;
        op = 1.0 - (1.0 - 0.18) * fallT;
      } else {
        op = 0.18;
      }
      maxOp = math.max(maxOp, op);
    }
    return maxOp;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Animated mark ─────────────────────────────────────────────────
          AnimatedBuilder(
            animation: Listenable.merge([
              _heartC,
              _breathC,
              _sparkC,
              _phaseAnim,
            ]),
            builder: (_, __) {
              final phase = _phaseAnim.value; // 0 = heartbeat, 1 = spark-seq

              // Core scale: blend between heartbeat pulse and calm breathe
              final coreScale =
                  _beatScale.value * (1 - phase) + _breathScale.value * phase;

              // Spark opacity: blend between heartbeat flare and seq wave
              final seqOp = _seqSparkOpacity(_sparkC.value);
              final sparkOp =
                  _heartSparkOpacity.value * (1 - phase) + seqOp * phase;

              return SizedBox(
                width: 36,
                height: 36,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.scale(
                      scale: coreScale,
                      child: SvgPicture.asset(
                        'assets/svgs/naiia-core.svg',
                        width: 36,
                        height: 36,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Opacity(
                      opacity: sparkOp.clamp(0.0, 1.0),
                      child: Transform.scale(
                        scale: coreScale,
                        child: SvgPicture.asset(
                          'assets/svgs/naiia-sparks.svg',
                          width: 36,
                          height: 36,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(width: 10),

          // ── Phase label ────────────────────────────────────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _nearResponse
                ? Text(
                    'responding…',
                    key: const ValueKey('responding'),
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.slateBlue,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  )
                : SizedBox(
                    width: 88,
                    key: const ValueKey('thinking'),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, anim) =>
                          FadeTransition(opacity: anim, child: child),
                      child: Text(
                        _words[_wordIndex],
                        key: ValueKey(_wordIndex),
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
          ),

          const SizedBox(width: 4),

          // ── Three dots ────────────────────────────────────────────────────
          AnimatedBuilder(
            animation: _heartC,
            builder: (_, __) => Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, _buildDot),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    final t = (_heartC.value * 3 + index) % 3;
    final opacity = (t < 1) ? t : (t < 2 ? 2 - t : 0.2);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1.5),
      child: Opacity(
        opacity: opacity.clamp(0.2, 1.0),
        child: Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _nearResponse ? AppColors.slateBlue : AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}
