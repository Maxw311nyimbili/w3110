import 'package:cap_project/features/chat/cubit/chat_cubit.dart';
import 'package:cap_project/features/chat/cubit/chat_state.dart' as models;
import 'package:cap_project/features/forum/cubit/forum_cubit.dart';
import 'package:cap_project/features/forum/cubit/forum_state.dart';
import 'package:cap_project/features/forum/widgets/answer_reader_with_comments.dart';
import 'package:cap_project/features/forum/widgets/new_post_sheet.dart';
import 'package:cap_project/features/chat/widgets/medicine_result_card.dart';
import 'package:forum_repository/forum_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/entry_animation.dart';

class RefinedMessageBubble extends StatelessWidget {
  const RefinedMessageBubble({required this.message, super.key});

  final models.ChatMessage message;

  @override
  Widget build(BuildContext context) {
    if (message.isUser) {
      return _buildUserMessage(context);
    } else {
      return _buildAIMessage(context);
    }
  }

  Widget _buildUserMessage(BuildContext context) {
    return EntryAnimation(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(48, 8, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.brandDarkTeal,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(4),
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brandDarkTeal.withOpacity(0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                message.content,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIMessage(BuildContext context) {
    // Use the persisted state from the message model
    final isDetailed = message.showingDetailedView;

    var content = isDetailed
        ? (message.detailedAnswer ?? message.content)
        : (message.quickAnswer ?? message.content);

    // 1. Calculate Sources Globally
    // We want sources to be available regardless of which view (Quick/Detailed) is active.
    // Priority: Structured sources -> Detailed Answer Text -> Quick Answer Text -> Content
    List<models.SourceReference> displaySources = List.from(message.sources);

    if (displaySources.isEmpty) {
      if (message.detailedAnswer != null) {
        displaySources.addAll(_extractSourcesFromText(message.detailedAnswer!));
      }
      if (displaySources.isEmpty && message.quickAnswer != null) {
        displaySources.addAll(_extractSourcesFromText(message.quickAnswer!));
      }
      if (displaySources.isEmpty) {
        displaySources.addAll(_extractSourcesFromText(message.content));
      }
    }

    // 2. Strip References from the CURRENTLY displayed content
    // We don't want to show the duplicate text list if we are showing cards
    // Robust finding of References section
    final referencesRegex = RegExp(
      r'(?:^|\n)(?:References|Sources):',
      caseSensitive: false,
    );
    final match = referencesRegex.firstMatch(content);
    if (match != null) {
      // Check if it looks like a references section (followed by bullets or content)
      // We just strip everything from the header onwards to be safe and clean
      content = content.substring(0, match.start).trim();
    }

    final hasSources = displaySources.isNotEmpty;

    return EntryAnimation(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: logo only + optional mode toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 32, // Larger logo
                    fit: BoxFit.contain,
                  ),
                  const Spacer(),
                  if (message.isDualMode) _buildModeToggle(context, isDetailed),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Sources Section (above the card)
            if (hasSources) ...[
              _buildSourceList(displaySources),
              const SizedBox(height: 12),
            ],

            // Medicine Result Card
            if (message.medicineResult != null)
              MedicineResultCard(result: message.medicineResult!),

            // Content area — No background card as per user request
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Minimal left teal accent bar (optional, can be removed if strictly no background means no bar)
                  Container(
                    width: 2,
                    height: 40, // Just a small accent
                    decoration: BoxDecoration(
                      color: AppColors.brandDarkTeal.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Main content
                  Expanded(
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      alignment: Alignment.topLeft,
                      child: BlocBuilder<ForumCubit, ForumState>(
                        builder: (context, forumState) {
                          final isForumOpen =
                              forumState.currentAnswerId == message.id;

                          if (isForumOpen) {
                            return AnswerReaderWithComments(
                              answerId: message.id,
                            );
                          }

                          return MarkdownBody(
                            data: content,
                            selectable: true,
                            fitContent: false,
                            onTapLink: (text, href, title) {
                              if (href != null) _launchURL(href);
                            },
                            styleSheet: MarkdownStyleSheet.fromTheme(
                              Theme.of(context),
                            ).copyWith(
                              p: AppTextStyles.bodyMedium.copyWith(
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                                height: 1.7,
                                fontSize: 15,
                              ),
                              pPadding: const EdgeInsets.only(bottom: 8),
                              strong: AppTextStyles.bodyMedium.copyWith(
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                              em: AppTextStyles.bodyMedium.copyWith(
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                                fontStyle: FontStyle.italic,
                                fontSize: 15,
                              ),
                              h1: AppTextStyles.displaySmall.copyWith(
                                color: Theme.of(context).textTheme.headlineLarge?.color,
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                              ),
                              h1Padding: const EdgeInsets.only(top: 16, bottom: 8),
                              h2: AppTextStyles.headlineLarge.copyWith(
                                color: AppColors.brandDarkTeal,
                                fontWeight: FontWeight.w700,
                              ),
                              h2Padding: const EdgeInsets.only(top: 14, bottom: 6),
                              h3: AppTextStyles.headlineMedium.copyWith(
                                color: Theme.of(context).textTheme.headlineMedium?.color,
                                fontWeight: FontWeight.w600,
                              ),
                              h3Padding: const EdgeInsets.only(top: 10, bottom: 4),
                              h4: AppTextStyles.headlineSmall.copyWith(
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                                fontWeight: FontWeight.w600,
                              ),
                              h4Padding: const EdgeInsets.only(top: 8, bottom: 2),
                              listBullet: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.brandDarkTeal,
                                fontSize: 15,
                              ),
                              listBulletPadding: const EdgeInsets.only(right: 8),
                              listIndent: 20,
                              blockSpacing: 12,
                              blockquote: AppTextStyles.bodyMedium.copyWith(
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                                fontStyle: FontStyle.italic,
                                fontSize: 15,
                              ),
                              blockquoteDecoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    color: AppColors.brandDarkTeal.withOpacity(0.6),
                                    width: 3,
                                  ),
                                ),
                                color: AppColors.brandDarkTeal.withOpacity(0.04),
                              ),
                              blockquotePadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              code: TextStyle(
                                backgroundColor: Theme.of(context).colorScheme.surface,
                                fontFamily: 'monospace',
                                fontSize: 13,
                                color: AppColors.brandDarkTeal,
                              ),
                              codeblockDecoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Theme.of(context).dividerColor.withOpacity(0.3),
                                ),
                              ),
                              codeblockPadding: const EdgeInsets.all(12),
                              tableHead: AppTextStyles.labelSmall.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                              tableBody: AppTextStyles.bodySmall.copyWith(
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                              tableBorder: TableBorder.all(
                                color: Theme.of(context).dividerColor.withOpacity(0.3),
                                width: 1,
                              ),
                              tableCellsPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              horizontalRuleDecoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: Theme.of(context).dividerColor.withOpacity(0.3),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildFooter(context, displaySources),
            ),

            // Teal-tinted separator
            const SizedBox(height: 16),
            Container(
              height: 1,
              decoration: BoxDecoration(
                color: AppColors.brandDarkTeal.withOpacity(0.07),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  List<models.SourceReference> _extractSourcesFromText(String text) {
    final List<models.SourceReference> sources = [];
    final referencesRegex = RegExp(
      r'(?:^|\n)(?:References|Sources):',
      caseSensitive: false,
    );
    final match = referencesRegex.firstMatch(text);

    if (match != null) {
      // Get everything after the "References:" header
      final referencesSection = text.substring(match.end).trim();
      final lines = referencesSection.split('\n');

      for (final line in lines) {
        final trimmedLine = line.trim();
        // Check if it looks like a list item
        if (trimmedLine.startsWith('*') ||
            trimmedLine.startsWith('-') ||
            RegExp(r'^\d+\.').hasMatch(trimmedLine)) {
          // Remove the bullet/number
          final sourceText = trimmedLine
              .replaceFirst(RegExp(r'^(\*|-|\d+\.)\s*'), '')
              .trim();

          if (sourceText.isNotEmpty) {
            // 1. Try to find a URL
            // exclude trailing punctuation like ) ] . ,
            final urlRegex = RegExp(r'https?://[^\s)\]]+');
            final urlMatch = urlRegex.firstMatch(sourceText);
            var url = urlMatch?.group(0) ?? '';

            // Clean the URL
            if (url.endsWith('.') || url.endsWith(',')) {
              url = url.substring(0, url.length - 1);
            }

            final title = sourceText
                .replaceAll(urlRegex, '')
                .trim()
                .replaceAll(RegExp(r'[\[\]()]'), '');

            // Fallback for missing URLs: Search Google
            final finalUrl = url.isNotEmpty
                ? url
                : 'https://www.google.com/search?q=${Uri.encodeComponent(title)}';

            final finalDomain = url.isNotEmpty
                ? (_extractDomain(url) ?? 'Source')
                : 'Google Search';

            sources.add(
              models.SourceReference(
                title: title.isEmpty ? 'Reference' : title,
                url: finalUrl,
                domain: finalDomain,
              ),
            );
          }
        }
      }
    }
    return sources;
  }

  Future<void> _launchURL(String url) async {
    if (url.isEmpty) return;
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  Widget _buildSourceList(List<models.SourceReference> sources) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, left: 4),
          child: Text(
            'Sources',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(
          height: 80, // Taller for better touch targets and visual presence
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: sources.length,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            separatorBuilder: (c, i) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final source = sources[index];
              return GestureDetector(
                onTap: () => _launchURL(source.url),
                child: Container(
                  width: 140,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).dividerColor.withOpacity(0.1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Clean Index Indicator
                          Container(
                            width: 16,
                            height: 16,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.accentLight,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.brandDarkTeal,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Domain
                          Expanded(
                            child: Text(
                              source.domain ??
                                  _extractDomain(source.url) ??
                                  'Source',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        source.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelSmall.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          height: 1.2,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
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

  // Helper just for the view if needed, though usually domain is passed
  String? _extractDomain(String url) {
    try {
      return Uri.parse(url).host.replaceAll('www.', '');
    } catch (_) {
      return null;
    }
  }

  Widget _buildModeToggle(BuildContext context, bool isDetailed) {
    return Container(
      height: 32, // Slightly taller
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleItem(context, 'Quick', !isDetailed),
          _buildToggleItem(context, 'Detailed', isDetailed),
        ],
      ),
    );
  }

  Widget _buildToggleItem(BuildContext context, String label, bool active) {
    return GestureDetector(
      onTap: () {
        context.read<ChatCubit>().toggleMessageView(message.id);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.brandDarkTeal : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.brandDarkTeal.withOpacity(0.18),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: active ? Colors.white : AppColors.textTertiary,
            fontWeight: active ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(
    BuildContext context,
    List<models.SourceReference> sources,
  ) {
    return Row(
      children: [
        _buildActionIcon(Icons.thumb_up_alt_outlined, () {}),
        const SizedBox(width: 8),
        _buildActionIcon(Icons.thumb_down_alt_outlined, () {}),
        const SizedBox(width: 8),
        _buildActionIcon(Icons.copy_rounded, () {}),
        const SizedBox(width: 8),
        _buildActionIcon(
          Icons.forum_outlined,
          () => context.read<ForumCubit>().toggleForumView(message.id),
        ), // Added Forum Discuss Action
        const SizedBox(width: 8),
        _buildActionIcon(
          Icons.share_outlined,
          () => _shareToForum(context, sources),
        ),
        const SizedBox(width: 8),
        _buildActionIcon(
          Icons.volume_up_rounded,
          () => _showListenMenu(context),
        ),
        const Spacer(),
        if (message.latencyMs != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.bolt_rounded,
                  size: 12,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${(message.latencyMs! / 1000).toStringAsFixed(1)}s',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildActionIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          icon,
          size: 18,
          color: AppColors.textTertiary, // Subtle icons
        ),
      ),
    );
  }

  void _showListenMenu(BuildContext context) {
    final chatCubit = context.read<ChatCubit>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
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
            Text(
              'Listen to Medical Response',
              style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...models.VoiceLanguage.values.map((lang) {
              return ListTile(
                leading: Icon(
                  Icons.play_circle_outline_rounded,
                  color: AppColors.brandDarkTeal,
                ),
                title: Text('Listen in ${lang.label}'),
                onTap: () {
                  Navigator.pop(modalContext);
                  // Pass the displayed content (quick or detailed) to synthesize
                  final textToSpeak = message.showingDetailedView
                      ? (message.detailedAnswer ?? message.content)
                      : (message.quickAnswer ?? message.content);
                  chatCubit.speakMessage(textToSpeak, lang);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Future<void> _shareToForum(
    BuildContext context,
    List<models.SourceReference> sources,
  ) async {
    final forumCubit = context.read<ForumCubit>();
    final content = message.content;

    // Show a quick loading snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preparing AI discussion...'),
        duration: Duration(milliseconds: 1500),
      ),
    );

    try {
      // Use the new AI-driven preparation endpoint
      final prepared = await forumCubit.preparePost(
        // Extract query from chat if possible, or fallback
        'Question about medical details', // Placeholder query
        content,
      );

      if (!context.mounted) return;

      final forumSources = sources
          .map(
            (s) => ForumPostSource(
              title: s.title,
              url: s.url,
              snippet: s.snippet,
            ),
          )
          .toList();

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (modalContext) => BlocProvider.value(
          value: forumCubit,
          child: NewPostSheet(
            initialTitle: prepared['title'] ?? '',
            initialContent: prepared['content'] ?? content,
            sources: forumSources,
            originalAnswerId: message.id,
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error preparing share: $e')),
      );
    }
  }
}
