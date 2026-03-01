import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class AudioPlaybackPill extends StatefulWidget {
  const AudioPlaybackPill({super.key});

  @override
  State<AudioPlaybackPill> createState() => _AudioPlaybackPillState();
}

class _AudioPlaybackPillState extends State<AudioPlaybackPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        if (!state.isSynthesizingAudio && !state.isPlayingAudio) {
          return const SizedBox.shrink();
        }

        final isTwi = state.playingLanguage == VoiceLanguage.twi || 
                     (state.isSynthesizingAudio && state.selectedLanguage == VoiceLanguage.twi);

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDark ? Colors.white : AppColors.textPrimary;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: AppColors.accentPrimary.withOpacity(isDark ? 0.35 : 0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.accentPrimary.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      state.isSynthesizingAudio ? Icons.bubble_chart_rounded : Icons.volume_up_rounded,
                      size: 16,
                      color: AppColors.accentPrimary,
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Text & Indicator
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            state.isSynthesizingAudio ? 'Thinking...' : 'Playing ',
                            style: AppTextStyles.labelSmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                          if (!state.isSynthesizingAudio)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.accentPrimary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isTwi ? 'TWI' : 'EN',
                                style: const TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      SizedBox(
                        height: 12,
                        child: state.isSynthesizingAudio 
                          ? _buildThinkingDots()
                          : _buildAudioWave(),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  // Stop Button
                  GestureDetector(
                    onTap: () => context.read<ChatCubit>().stopAudio(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: textColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildThinkingDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _waveController,
          builder: (context, _) {
            final phase = (_waveController.value + i / 3.0) % 1.0;
            final opacity = 0.3 + sin(phase * pi).abs() * 0.7;
            return Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.only(right: 3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentPrimary.withOpacity(opacity),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildAudioWave() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(8, (i) {
        return AnimatedBuilder(
          animation: _waveController,
          builder: (context, _) {
            final phase = (_waveController.value + i / 8.0) % 1.0;
            final height = 3.0 + sin(phase * pi).abs() * 9.0;
            return Container(
              width: 2,
              height: height,
              margin: const EdgeInsets.only(right: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1),
                color: AppColors.accentPrimary.withOpacity(0.8),
              ),
            );
          },
        );
      }),
    );
  }
}
