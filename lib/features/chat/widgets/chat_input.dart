import 'package:cap_project/app/view/app_router.dart';
import 'package:cap_project/features/chat/widgets/audio_waveform.dart';
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

class _RefinedChatInputState extends State<RefinedChatInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
                    icon: Icons.image_outlined,
                    label: 'Image',
                    onTap: () {
                      Navigator.pop(context);
                      AppRouter.navigateTo(context, AppRouter.scanner, arguments: 'gallery');
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSquarePickerOption(
                    icon: Icons.camera_alt_outlined,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      AppRouter.navigateTo(context, AppRouter.scanner, arguments: 'camera');
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
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.backgroundPrimary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.gray200.withOpacity(0.5), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 32),
            const SizedBox(height: 12),
            Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundPrimary,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundSurface,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: widget.isAudioMode ? _buildAudioBar() : _buildInputBar(),
      ),
    );
  }

  Widget _buildInputBar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            maxLines: 5,
            minLines: 1,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Ask anything...',
              hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 20),
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
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: canSend ? AppColors.accentPrimary : AppColors.gray200,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_upward_rounded,
                        size: 22,
                        color: Colors.white,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.textTertiary),
            onPressed: widget.onToggleAudio,
          ),
          const Expanded(
            child: SizedBox(
               height: 60,
               child: Center(child: AudioWaveform()),
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.stop_rounded, color: AppColors.error, size: 28),
                onPressed: widget.onToggleAudio,
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_outlined, color: AppColors.textSecondary),
            onPressed: widget.onToggleAudio,
          ),
        ],
      ),
    );
  }
}
