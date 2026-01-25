import 'package:cap_project/features/chat/cubit/chat_cubit.dart';
import 'package:cap_project/features/chat/cubit/chat_state.dart';
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
import 'package:chat_repository/chat_repository.dart' hide ChatMessage, SourceReference;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class RefinedMessageBubble extends StatelessWidget {
  const RefinedMessageBubble({required this.message, super.key});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    if (message.isUser) {
      return _buildUserMessage(context);
    } else {
      return _buildAIMessage(context);
    }
  }

  Widget _buildUserMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(48, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.accentPrimary, // Vibrant accent color
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(4), // Rounded corner flip for right side
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentPrimary.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              message.content,
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white, // White text on accent
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ),
        ],
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
    List<SourceReference> displaySources = List.from(message.sources);
    
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
    final referencesRegex = RegExp(r'(?:^|\n)(?:References|Sources):', caseSensitive: false);
    final match = referencesRegex.firstMatch(content);
    if (match != null) {
      // Check if it looks like a references section (followed by bullets or content)
      // We just strip everything from the header onwards to be safe and clean
      content = content.substring(0, match.start).trim();
    }

    final hasSources = displaySources.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Icon and Toggle
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.accentPrimary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 16,
                  color: AppColors.accentPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Thanzi AI',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (message.isDualMode)
                _buildModeToggle(context, isDetailed),
            ],
          ),
          
          const SizedBox(height: 12),

          // Sources Section
          if (hasSources) ...[
            _buildSourceList(displaySources),
            const SizedBox(height: 16),
          ],

          // Medicine Result Card (If present)
          if (message.medicineResult != null)
            MedicineResultCard(result: message.medicineResult!),

          // Content Area (Clean, no container)
          Padding(
            padding: const EdgeInsets.only(left: 0),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.topLeft,
              child: BlocBuilder<ForumCubit, ForumState>(
                builder: (context, forumState) {
                  final isForumOpen = forumState.currentAnswerId == message.id;
                  
                  if (isForumOpen) {
                    return AnswerReaderWithComments(answerId: message.id);
                  }
                  
                  return MarkdownBody(
                    data: content,
                    selectable: true,
                    onTapLink: (text, href, title) {
                      if (href != null) _launchURL(href);
                    },
                    styleSheet: MarkdownStyleSheet(
                      p: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.6,
                        fontSize: 16,
                      ),
                      strong: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      h1: AppTextStyles.headlineMedium,
                      h2: AppTextStyles.headlineSmall,
                      code: TextStyle(
                        backgroundColor: AppColors.backgroundSurface,
                        fontFamily: 'monospace',
                        fontSize: 14,
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: AppColors.backgroundSurface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 16),
          _buildFooter(context, displaySources),
          
          // Separator line for visual break
          const SizedBox(height: 24),
          const Divider(height: 1, color: AppColors.gray200),
        ],
      ),
    );
  }

  List<SourceReference> _extractSourcesFromText(String text) {
    final List<SourceReference> sources = [];
    final referencesRegex = RegExp(r'(?:^|\n)(?:References|Sources):', caseSensitive: false);
    final match = referencesRegex.firstMatch(text);
    
    if (match != null) {
      // Get everything after the "References:" header
      final referencesSection = text.substring(match.end).trim();
      final lines = referencesSection.split('\n');
      
      for (final line in lines) {
        final trimmedLine = line.trim();
        // Check if it looks like a list item
        if (trimmedLine.startsWith('*') || trimmedLine.startsWith('-') || RegExp(r'^\d+\.').hasMatch(trimmedLine)) {
           // Remove the bullet/number
           final sourceText = trimmedLine.replaceFirst(RegExp(r'^(\*|-|\d+\.)\s*'), '').trim();
           
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

             final title = sourceText.replaceAll(urlRegex, '').trim().replaceAll(RegExp(r'[\[\]()]'), '');
             
             // Fallback for missing URLs: Search Google
             final finalUrl = url.isNotEmpty 
                 ? url 
                 : 'https://www.google.com/search?q=${Uri.encodeComponent(title)}';
             
             final finalDomain = url.isNotEmpty 
                 ? (_extractDomain(url) ?? 'Source') 
                 : 'Google Search';

             sources.add(SourceReference(
               title: title.isEmpty ? 'Reference' : title,
               url: finalUrl,
               domain: finalDomain,
             ));
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

  Widget _buildSourceList(List<SourceReference> sources) {
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
                    color: AppColors.backgroundSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight.withOpacity(0.6), width: 1),
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
                               color: AppColors.gray100,
                               shape: BoxShape.circle,
                             ),
                             child: Text(
                               '${index + 1}',
                               style: const TextStyle(
                                 fontSize: 10,
                                 fontWeight: FontWeight.bold,
                                 color: AppColors.textSecondary,
                               ),
                             ),
                           ),
                           const SizedBox(width: 8),
                           // Domain
                           Expanded(
                             child: Text(
                               source.domain ?? _extractDomain(source.url) ?? 'Source',
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
                          color: AppColors.textPrimary,
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
        color: AppColors.gray100,
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
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: active ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(0, 1),
            )
          ] : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: active ? AppColors.textPrimary : AppColors.textTertiary,
            fontWeight: active ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, List<SourceReference> sources) {
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
                const Icon(Icons.bolt_rounded, size: 12, color: AppColors.textSecondary),
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

  void _shareToForum(BuildContext context, List<SourceReference> sources) {
    final content = message.content;
    
    // Map Chat sources to Forum sources
    final forumSources = sources.map((s) => ForumPostSource(
      title: s.title,
      url: s.url,
      snippet: s.snippet,
    )).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundSurface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: BlocProvider.value(
          value: context.read<ForumCubit>(),
          child: NewPostSheet(
            initialTitle: 'Discussion on: ${content.length > 30 ? '${content.substring(0, 30)}...' : content}',
            initialContent: content,
            sources: forumSources,
          ),
        ),
      ),
    );
  }
}
