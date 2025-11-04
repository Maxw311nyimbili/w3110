// lib/features/chat/widgets/message_bubble.dart
// PREMIUM DESIGN - Tight spacing, clear attribution

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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
        message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // AI avatar + message (left)
          if (!message.isUser) ...[
            _buildMedLinkAvatar(),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMessageCard(context),
                  if (message.overallConfidence != null) ...[
                    const SizedBox(height: 6),
                    ConfidenceIndicator(
                      confidence: message.overallConfidence!,
                      level: message.confidenceLevel,
                    ),
                  ],
                  if (message.sentences.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _buildCitedSources(context),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    _formatTimestamp(message.timestamp),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
          // User message + avatar (right)
          if (message.isUser) ...[
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildMessageCard(context),
                  const SizedBox(height: 4),
                  Text(
                    _formatTimestamp(message.timestamp),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildUserAvatar(),
          ],
        ],
      ),
    );
  }

  /// MedLink branded avatar - compact and tight
  Widget _buildMedLinkAvatar() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentPrimary,
            AppColors.accentPrimary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentPrimary.withOpacity(0.2),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.medical_services_outlined,
          size: 14,
          color: Colors.white,
        ),
      ),
    );
  }

  /// User avatar - compact and tight
  Widget _buildUserAvatar() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.backgroundElevated,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.gray200,
          width: 0.5,
        ),
      ),
      child: Icon(
        Icons.person_rounded,
        size: 14,
        color: AppColors.textSecondary,
      ),
    );
  }

  /// Compact message card - tighter padding
  Widget _buildMessageCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: message.isUser ? AppColors.accentLight : AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(11).copyWith(
          topLeft: message.isUser ? const Radius.circular(11) : Radius.zero,
          topRight: message.isUser ? Radius.zero : const Radius.circular(11),
          bottomLeft: const Radius.circular(11),
          bottomRight: const Radius.circular(11),
        ),
        border: message.isUser
            ? null
            : Border.all(
          color: AppColors.gray200,
          width: 0.5,
        ),
        boxShadow: !message.isUser
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 2,
            offset: const Offset(0, 0.5),
          ),
        ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.imageUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                message.imageUrl!,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 140,
                    color: AppColors.gray200,
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 24),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            message.content,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// Compact source citations
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
          'Sources',
          style: AppTextStyles.labelSmall.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textTertiary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: sourcesList.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final source = entry.value;
            return _buildSourceChip(context, index, source);
          }).toList(),
        ),
      ],
    );
  }

  /// Compact source chip
  Widget _buildSourceChip(
      BuildContext context, int index, SourceReference source) {
    return InkWell(
      onTap: () => _showSourcePreview(context, source, index),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.backgroundElevated,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.gray200, width: 0.5),
        ),
        child: Text(
          '[$index]',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.accentPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 10,
          ),
        ),
      ),
    );
  }

  /// Source preview modal
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
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.link,
                      color: AppColors.accentPrimary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Source [$index]',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 24),
              Text(
                source.title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.backgroundElevated,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.language,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        source.url,
                        style: AppTextStyles.labelSmall.copyWith(
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
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSurface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.gray200, width: 0.5),
                  ),
                  child: Text(
                    source.snippet!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _launchURL(context, source.url);
                  },
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: const Text('Open Source'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
        _showError(context, 'Error opening link');
      }
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
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
}