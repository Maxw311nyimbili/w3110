import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cap_project/core/theme/app_colors.dart';

/// Modern amplitude-history waveform.
///
/// As the user speaks, each new microphone amplitude sample is pushed into a
/// rolling 40-slot buffer. The buffer scrolls left on every tick so old bars
/// drift off the left edge — giving the same feel as Telegram or Apple's voice
/// memo waveform (real signal history, not a synthetic sine wave).
class AudioWaveform extends StatefulWidget {
  final bool isRecording;

  /// Raw dB value from the microphone. Typically -160 (silence) to 0 (max).
  final double amplitude;

  const AudioWaveform({
    super.key,
    this.isRecording = false,
    this.amplitude = -160.0,
  });

  @override
  State<AudioWaveform> createState() => _AudioWaveformState();
}

class _AudioWaveformState extends State<AudioWaveform>
    with SingleTickerProviderStateMixin {
  static const int _barCount = 40;
  static const int _sampleIntervalMs = 80;
  static const double _barWidth = 3.0;
  static const double _barGap = 2.0;
  static const double _minBarHeight = 3.0;
  static const double _maxBarHeight = 40.0;

  // Rolling amplitude history — newest sample at the end
  final List<double> _history = List.filled(_barCount, 0.0);

  Timer? _sampleTimer;

  // Idle breathing controller
  late AnimationController _idleController;
  late Animation<double> _idleAnim;

  @override
  void initState() {
    super.initState();
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _idleAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOut),
    );

    if (widget.isRecording) _startSampling();
  }

  @override
  void didUpdateWidget(AudioWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !oldWidget.isRecording) {
      _startSampling();
    } else if (!widget.isRecording && oldWidget.isRecording) {
      _stopSampling();
    }
  }

  void _startSampling() {
    _sampleTimer?.cancel();
    _sampleTimer = Timer.periodic(
      const Duration(milliseconds: _sampleIntervalMs),
      (_) {
        if (!mounted) return;
        setState(() {
          // Normalise dB: -160 (silence) → 0.0, 0 (peak) → 1.0
          final norm = ((widget.amplitude + 160) / 160).clamp(0.0, 1.0);
          // Add a small amount of per-bar jitter so identical frames still look organic
          final jitter = (Random().nextDouble() - 0.5) * 0.08;
          _history.removeAt(0);
          _history.add((norm + jitter).clamp(0.0, 1.0));
        });
      },
    );
  }

  void _stopSampling() {
    _sampleTimer?.cancel();
    _sampleTimer = null;
    if (mounted) setState(() => _history.fillRange(0, _barCount, 0.0));
  }

  @override
  void dispose() {
    _sampleTimer?.cancel();
    _idleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isRecording) {
      return _buildIdleState();
    }
    return _buildLiveWaveform();
  }

  /// Idle: three small centered dots with a slow breathing animation.
  Widget _buildIdleState() {
    return AnimatedBuilder(
      animation: _idleAnim,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final phase = (i - 1) * 0.4;
            final val = (sin((_idleController.value * 2 * pi) + phase) + 1) / 2;
            final h = _minBarHeight + val * 10;
            return Container(
              width: _barWidth,
              height: h,
              margin: const EdgeInsets.symmetric(horizontal: _barGap / 2),
              decoration: BoxDecoration(
                color: AppColors.brandDarkTeal.withOpacity(0.35),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }

  /// Live: 40-bar scrolling history, newest bars on the right.
  Widget _buildLiveWaveform() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(_barCount, (i) {
        final normVal = _history[i];
        final barH = (_minBarHeight + normVal * (_maxBarHeight - _minBarHeight))
            .clamp(_minBarHeight, _maxBarHeight);

        // Bars fade toward the left edge (oldest = more transparent)
        final opacity = 0.25 + (i / _barCount) * 0.75;

        return AnimatedContainer(
          duration: const Duration(milliseconds: _sampleIntervalMs),
          curve: Curves.easeOut,
          width: _barWidth,
          height: barH,
          margin: const EdgeInsets.symmetric(horizontal: _barGap / 2),
          decoration: BoxDecoration(
            color: AppColors.brandDarkTeal.withOpacity(opacity),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}
