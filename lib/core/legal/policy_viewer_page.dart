import 'package:flutter/material.dart';
import 'legal_content.dart';

/// Full-screen scrollable viewer for Privacy Policy or Terms of Service.
///
/// Usage:
/// ```dart
/// Navigator.push(context, MaterialPageRoute(
///   builder: (_) => PolicyViewerPage(
///     title: kPrivacyPolicyTitle,
///     effectiveDate: kPrivacyPolicyDate,
///     sections: kPrivacySections,
///   ),
/// ));
/// ```
class PolicyViewerPage extends StatelessWidget {
  const PolicyViewerPage({
    required this.title,
    required this.effectiveDate,
    required this.sections,
    super.key,
  });

  final String title;
  final String effectiveDate;
  final List<PolicySection> sections;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20,
              color: theme.textTheme.bodyLarge?.color),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Effective date chip
                Container(
                  margin: const EdgeInsets.only(bottom: 28),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    effectiveDate,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: primary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),

                // Sections
                ...sections.map((section) => _SectionWidget(section: section)),

                const SizedBox(height: 24),

                // Footer
                Text(
                  'If you have questions about this document, contact us at nyimbilimaxwell9@gmail.com.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionWidget extends StatelessWidget {
  const _SectionWidget({required this.section});
  final PolicySection section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section heading
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              section.heading,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
                letterSpacing: -0.2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Body text
          Text(
            section.body,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color,
              height: 1.65,
            ),
          ),
          const SizedBox(height: 4),
          Divider(
            color: theme.dividerColor.withOpacity(0.08),
            height: 1,
          ),
        ],
      ),
    );
  }
}
