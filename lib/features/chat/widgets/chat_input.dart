import 'dart:io';
import 'package:cap_project/app/view/app_router.dart';
import 'package:cap_project/features/medscanner/cubit/medscanner_state.dart' as scanner;
import 'package:cap_project/features/chat/widgets/audio_waveform.dart';
import 'package:cap_project/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class RefinedChatInput extends StatefulWidget {
  final bool isAudioMode;
  final VoidCallback onToggleAudio;

  const RefinedChatInput({
    super.key,
    required this.isAudioMode,
    required this.onToggleAudio,
  });

  @override
  State<RefinedChatInput> createState() => _RefinedChatInputState();
}

class _RefinedChatInputState extends State<RefinedChatInput> with TickerProviderStateMixin {
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
    final chatCubit = context.read<ChatCubit>(); // Capture cubit from valid context

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gray200,
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
                    color: AppColors.accentPrimary,
                    onTap: () async {
                      // Close the bottom sheet FIRST
                      Navigator.pop(modalContext);
                      _focusNode.unfocus(); // Ensure focus doesn't return
                      
                      // Then navigate to scanner
                      final result = await AppRouter.navigateTo(context, AppRouter.scanner);
                      
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
                    color: AppColors.accentSecondary,
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
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.backgroundPrimary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.gray200.withOpacity(0.5), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color ?? AppColors.textPrimary, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
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
      listenWhen: (previous, current) => previous.error != current.error && current.error != null,
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.read<ChatCubit>().clearError();
        }
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        decoration: BoxDecoration(
          color: AppColors.backgroundPrimary,
          border: Border(
            top: BorderSide(
              color: AppColors.borderLight.withOpacity(0.8),
              width: 1,
            ),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundSurface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppColors.borderLight, 
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
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
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).askAnything,
                hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
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
                icon: const Icon(Icons.add_rounded, color: AppColors.textSecondary, size: 28),
                onPressed: _showPlusMenu,
              ),
              const Spacer(),
              if (!_hasText)
                IconButton(
                  icon: const Icon(Icons.mic_none_rounded, color: AppColors.textSecondary, size: 26),
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
                          color: canSend ? AppColors.accentPrimary : AppColors.borderLight,
                          shape: BoxShape.circle,
                          boxShadow: canSend ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ] : null,
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
                icon: const Icon(Icons.close_rounded, color: AppColors.textTertiary),
                onPressed: () {
                  context.read<ChatCubit>().cancelRecording();
                  widget.onToggleAudio();
                },
              ),
              Expanded(
                child: SizedBox(
                   height: 60,
                   child: Center(
                     child: AudioWaveform(
                       isRecording: state.isRecording,
                       amplitude: state.amplitude,
                     ),
                   ),
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
                          color: AppColors.error.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const Icon(
                        Icons.stop_rounded,
                        color: AppColors.error,
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
                              CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
                            ),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.accentPrimary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.mic_rounded,
                            color: AppColors.accentPrimary,
                            size: 28,
                          ),
                        ],
                      ),
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.keyboard_outlined, color: AppColors.textSecondary),
                onPressed: widget.onToggleAudio,
              ),
            ],
          ),
        );
      },
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
              children: state.pendingAttachments.map((attachment) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundPrimary,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: attachment.type == AttachmentType.image
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  File(attachment.path),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined, size: 20),
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.description_rounded, color: Colors.blue),
                                  const SizedBox(height: 4),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
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
                          onTap: () => context.read<ChatCubit>().removeAttachment(attachment.path),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 14),
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
