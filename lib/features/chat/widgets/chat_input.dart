import 'dart:io';
import 'package:cap_project/app/view/app_router.dart';
import 'package:cap_project/core/widgets/glass_card.dart';
import 'package:cap_project/features/medscanner/cubit/medscanner_state.dart'
    as scanner;
import 'package:cap_project/features/chat/widgets/audio_waveform.dart';
import 'package:cap_project/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/cubit.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class RefinedChatInput extends StatefulWidget {
  final bool isAudioMode;
  final VoidCallback onToggleAudio;
  final bool isLandingMode;

  const RefinedChatInput({
    super.key,
    required this.isAudioMode,
    required this.onToggleAudio,
    this.isLandingMode = false,
  });

  @override
  State<RefinedChatInput> createState() => _RefinedChatInputState();
}

class _RefinedChatInputState extends State<RefinedChatInput>
    with TickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.isAudioMode) _pulseController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(RefinedChatInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAudioMode && !oldWidget.isAudioMode) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isAudioMode && oldWidget.isAudioMode) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    context.read<ChatCubit>().sendMessage(_controller.text.trim());
    _controller.clear();
    setState(() => _hasText = false);
  }

  void _showPlusMenu() {
    _focusNode.unfocus(); // Ensure keyboard is dismissed when menu opens
    final chatCubit = context
        .read<ChatCubit>(); // Capture cubit from valid context

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => GlassCard(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        borderRadius: 28,
        tintOpacity: 0.96,
        blur: 16,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildSquarePickerOption(
                    icon: Icons.center_focus_strong_rounded,
                    label: 'Scan Medicine',
                    color: Theme.of(context).colorScheme.primary,
                    onTap: () async {
                      Navigator.pop(modalContext);
                      _focusNode.unfocus(); // Ensure focus doesn't return

                      // Then navigate to scanner
                      final result = await AppRouter.navigateTo(
                        context,
                        AppRouter.scanner,
                      );

                      // Handle result if we are still mounted
                      if (context.mounted && result is scanner.ScanResult) {
                        chatCubit.addMedicineResult(result);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSquarePickerOption(
                    icon: Icons.description_outlined,
                    label: 'Document',
                    color: AppColors.accentSecondary,
                    onTap: () {
                      Navigator.pop(modalContext);
                      _focusNode.unfocus(); // Ensure focus doesn't return
                      // Use a slight delay to ensure the bottom sheet is closed before picking
                      // which sometimes helps with overlay issues
                      Future.delayed(const Duration(milliseconds: 200), () {
                        if (context.mounted) {
                          chatCubit.pickDocument();
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSquarePickerOption(
                    icon: Icons.photo_library_outlined,
                    label: 'Gallery',
                    color: Theme.of(context).colorScheme.secondary,
                    onTap: () {
                      Navigator.pop(modalContext);
                      _focusNode.unfocus(); // Ensure focus doesn't return
                      Future.delayed(const Duration(milliseconds: 200), () {
                        if (context.mounted) {
                          chatCubit.pickImage();
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSquarePickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color ?? AppColors.brandDarkTeal, size: 26),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatCubit, ChatState>(
      listenWhen: (previous, current) =>
          previous.error != current.error && current.error != null,
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.read<ChatCubit>().clearError();
        }
      },
      child: Container(
        padding: widget.isLandingMode
            ? const EdgeInsets.symmetric(horizontal: 0, vertical: 0)
            : const EdgeInsets.fromLTRB(16, 4, 16, 8),
        decoration: BoxDecoration(
          color: widget.isLandingMode
              ? Colors.transparent
              : Theme.of(context).scaffoldBackgroundColor,
          border: widget.isLandingMode
              ? null
              : Border(
                  top: BorderSide(
                    color: Theme.of(context).dividerColor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
        ),
        child: Container(
          constraints: widget.isLandingMode
              ? const BoxConstraints(maxWidth: 720)
              : null,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).dividerColor.withOpacity(0.08)
                  : AppColors.accentLight.withOpacity(0.7),
              width: 1.0,
            ),
            boxShadow: widget.isLandingMode
                ? [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                      blurRadius: 32,
                      spreadRadius: -4,
                      offset: const Offset(0, 12),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: widget.isAudioMode ? _buildAudioBar() : _buildInputBar(),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAttachmentPreview(),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 12, 0),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            maxLines: 6, // predictable growth limit
            minLines: 1,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).askAnything,
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.labelSmall?.color,
              ),
              filled: false, // Override global theme
              fillColor: Colors.transparent,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.add_rounded,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  size: 28,
                ),
                onPressed: _showPlusMenu,
              ),
              const Spacer(),
              if (!_hasText)
                IconButton(
                  icon: Icon(
                    Icons.mic_none_rounded,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    size: 26,
                  ),
                  onPressed: widget.onToggleAudio,
                ),
              const SizedBox(width: 8),
              BlocBuilder<ChatCubit, ChatState>(
                builder: (context, state) {
                  final canSend = _hasText && !state.isTyping;
                  return GestureDetector(
                    onTap: canSend ? _sendMessage : null,
                    child: AnimatedScale(
                      scale: canSend ? 1.0 : 0.9,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: canSend
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).dividerColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                          boxShadow: canSend
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: const Icon(
                          Icons.arrow_upward_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAudioBar() {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: Theme.of(context).textTheme.labelSmall?.color,
                ),
                onPressed: () {
                  context.read<ChatCubit>().cancelRecording();
                  widget.onToggleAudio();
                },
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLanguageSelector(state),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 44,
                      child: Center(
                        child: AudioWaveform(
                          isRecording: state.isRecording,
                          amplitude: state.amplitude,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (state.isRecording) {
                    context.read<ChatCubit>().stopRecording();
                  } else {
                    context.read<ChatCubit>().startRecording();
                  }
                },
                child: state.isRecording
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const Icon(
                            Icons.stop_rounded,
                            color: Colors.red,
                            size: 28,
                          ),
                        ],
                      )
                    : FadeTransition(
                        opacity: _pulseController,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ScaleTransition(
                              scale: Tween(begin: 1.0, end: 1.2).animate(
                                CurvedAnimation(
                                  parent: _pulseController,
                                  curve: Curves.easeInOut,
                                ),
                              ),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(
                                    0.1,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.mic_rounded,
                              color: Theme.of(context).colorScheme.primary,
                              size: 28,
                            ),
                          ],
                        ),
                      ),
              ),
              IconButton(
                icon: Icon(
                  Icons.keyboard_outlined,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                onPressed: widget.onToggleAudio,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageSelector(ChatState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: VoiceLanguage.values.map<Widget>((lang) {
        final isSelected = state.selectedLanguage == lang;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: GestureDetector(
            onTap: () => context.read<ChatCubit>().updateLanguage(lang),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).dividerColor.withOpacity(0.1),
                ),
              ),
              child: Text(
                lang.label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyMedium?.color,
                  fontWeight: isSelected ? FontWeight.bold : null,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAttachmentPreview() {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        if (state.pendingAttachments.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: state.pendingAttachments.map<Widget>((attachment) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                        ),
                        child: attachment.type == AttachmentType.image
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  File(attachment.path),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.broken_image_outlined,
                                    size: 20,
                                  ),
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.description_rounded,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(height: 4),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: Text(
                                      attachment.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      Positioned(
                        top: -6,
                        right: -6,
                        child: GestureDetector(
                          onTap: () => context
                              .read<ChatCubit>()
                              .removeAttachment(attachment.path),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
