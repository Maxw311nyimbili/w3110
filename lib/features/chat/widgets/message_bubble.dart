// lib/features/chat/widgets/message_bubble.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../cubit/cubit.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'confidence_indicator.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    required this.message,
    super.key,
  });

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment:
        message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            _buildAvatar(context, isUser: false),
            const SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                _buildMessageCard(context),
                if (!message.isUser && message.overallConfidence != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  ConfidenceIndicator(
                    confidence: message.overallConfidence!,
                    level: message.confidenceLevel,
                  ),
                ],
                if (!message.isUser) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _buildCitedSources(context),
                ],
                const SizedBox(height: AppSpacing.xs),
                _buildTimestamp(context),
              ],
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: AppSpacing.sm),
            _buildAvatar(context, isUser: true),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, {required bool isUser}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isUser ? AppColors.accentPrimary : AppColors.gray200,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          isUser ? Icons.person : Icons.medical_services_outlined,
          size: 18,
          color: isUser ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildMessageCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: message.isUser
            ? AppColors.accentLight
            : AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(16).copyWith(
          topLeft: message.isUser ? const Radius.circular(16) : Radius.zero,
          topRight: message.isUser ? Radius.zero : const Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.imageUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                message.imageUrl!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    color: AppColors.gray200,
                    child: const Center(
                      child: Icon(Icons.broken_image),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          Text(
            message.content,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCitedSources(BuildContext context) {
    final citedSources = <SourceReference>{};

    for (final sentence in message.sentences) {
      if (sentence.sources != null && sentence.sources!.isNotEmpty) {
        citedSources.addAll(sentence.sources!);
      }
    }

    if (citedSources.isEmpty) {
      return const SizedBox.shrink();
    }

    final sourcesList = citedSources.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sources:',
          style: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: sourcesList.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final source = entry.value;
            return _buildSourceChip(context, index, source);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSourceChip(
      BuildContext context, int index, SourceReference source) {
    return InkWell(
      onTap: () => _showSourcePreview(context, source, index), // Changed: Show preview first
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.gray100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gray300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.link,
              size: 14,
              color: AppColors.accentPrimary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '[$index]',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.accentPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSourcePreview(
      BuildContext context, SourceReference source, int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accentLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.link,
                      color: AppColors.accentPrimary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Source [$index]',
                      style: AppTextStyles.headlineMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 24),
              const SizedBox(height: AppSpacing.md),
              Text(
                source.title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.language,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        source.url,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (source.snippet != null) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSurface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.gray300),
                  ),
                  child: Text(
                    source.snippet!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _launchURL(context, source.url);
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open in Browser'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimestamp(BuildContext context) {
    final timeStr = _formatTimestamp(message.timestamp);
    return Text(
      timeStr,
      style: AppTextStyles.labelSmall.copyWith(
        color: AppColors.textTertiary,
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _launchURL(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (context.mounted) {
          _showError(context, 'Could not open link');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Error opening link: $e');
      }
    }
  }

  void _showSourceDetail(
      BuildContext context, SourceReference source, int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accentLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.link,
                      color: AppColors.accentPrimary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Source [$index]',
                      style: AppTextStyles.headlineMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                source.title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                source.url,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.accentPrimary,
                  decoration: TextDecoration.underline,
                ),
              ),
              if (source.snippet != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  source.snippet!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _launchURL(context, source.url);
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open in Browser'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}