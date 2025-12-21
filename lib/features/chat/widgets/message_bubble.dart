import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import '../cubit/chat_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class RefinedMessageBubble extends StatefulWidget {
  const RefinedMessageBubble({required this.message, super.key});

  final ChatMessage message;

  @override
  State<RefinedMessageBubble> createState() => _RefinedMessageBubbleState();
}

class _RefinedMessageBubbleState extends State<RefinedMessageBubble> {
  bool _isDetailed = false;

  @override
  void initState() {
    super.initState();
    // Default to detailed if it's dual mode, otherwise quick
    _isDetailed = widget.message.isDualMode;
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.isUser;
    
    if (isUser) {
      return _buildUserMessage(context);
    } else {
      return _buildAIMessage(context);
    }
  }

  Widget _buildUserMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(48, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.backgroundSurface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              widget.message.content,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIMessage(BuildContext context) {
    final hasSources = widget.message.sources.isNotEmpty;
    final content = _isDetailed 
        ? (widget.message.detailedAnswer ?? widget.message.content)
        : (widget.message.quickAnswer ?? widget.message.content);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasSources) ...[
            _buildSourceList(widget.message.sources),
            const SizedBox(height: 24),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.accentPrimary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Thanzi AI',
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (widget.message.isDualMode)
                _buildModeToggle(),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: MarkdownBody(
                data: content,
                selectable: true,
                onTapLink: (text, href, title) {
                  if (href != null) launchUrl(Uri.parse(href));
                },
                styleSheet: MarkdownStyleSheet(
                  p: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.6,
                    letterSpacing: 0.1,
                  ),
                  strong: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  listBullet: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildSourceList(List<SourceReference> sources) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.menu_book_outlined, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              'SOURCES',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: sources.length,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              final source = sources[index];
              return GestureDetector(
                onTap: () => launchUrl(Uri.parse(source.url)),
                child: Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.gray200, width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        source.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          if (source.domain != null) ...[
                            Flexible(
                              child: Text(
                                source.domain!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.circle, size: 2, color: AppColors.textTertiary),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            '${index + 1}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textTertiary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildModeToggle() {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleItem('Quick', !_isDetailed),
          _buildToggleItem('Detailed', _isDetailed),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String label, bool active) {
    return GestureDetector(
      onTap: () => setState(() => _isDetailed = label == 'Detailed'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: active ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ] : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: active ? AppColors.textPrimary : AppColors.textTertiary,
            fontWeight: active ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          _buildActionIcon(Icons.copy_rounded, () {}),
          const SizedBox(width: 16),
          _buildActionIcon(Icons.share_outlined, () {}),
          const SizedBox(width: 16),
          _buildActionIcon(Icons.thumb_up_outlined, () {}),
          const SizedBox(width: 16),
          _buildActionIcon(Icons.thumb_down_outlined, () {}),
          const Spacer(),
          if (widget.message.latencyMs != null)
            Text(
              '${(widget.message.latencyMs! / 1000).toStringAsFixed(1)}s',
              style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
            ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          icon,
          size: 18,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}
