import 'package:cap_project/core/locale/cubit/locale_cubit.dart';
import 'package:cap_project/core/locale/cubit/locale_state.dart';
import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Bottom sheet for selecting application language
class LanguageSelectorBottomSheet extends StatelessWidget {
  const LanguageSelectorBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const LanguageSelectorBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                'Select Language',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Language options
            BlocBuilder<LocaleCubit, LocaleState>(
              builder: (context, state) {
                final primaryLocales = LocaleState.supportedLocales.where(
                  (l) => l.languageCode == 'en' || l.languageCode == 'tw',
                ).toList();
                
                final otherLocales = LocaleState.supportedLocales.where(
                  (l) => l.languageCode == 'ar' || l.languageCode == 'fr',
                ).toList();

                return _LanguageListContent(
                  state: state,
                  primaryLocales: primaryLocales,
                  otherLocales: otherLocales,
                );
              },
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _LanguageListContent extends StatefulWidget {
  const _LanguageListContent({
    required this.state,
    required this.primaryLocales,
    required this.otherLocales,
  });

  final LocaleState state;
  final List<Locale> primaryLocales;
  final List<Locale> otherLocales;

  @override
  State<_LanguageListContent> createState() => _LanguageListContentState();
}

class _LanguageListContentState extends State<_LanguageListContent> {
  bool _showOthers = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Primary Section
        ...widget.primaryLocales.map((locale) {
          final isSelected = widget.state.locale.languageCode == locale.languageCode;
          return _LanguageOption(
            locale: locale,
            isSelected: isSelected,
            onTap: () {
              context.read<LocaleCubit>().changeLocale(locale);
              Navigator.pop(context);
            },
          );
        }),

        // Divider & More button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            children: [
              Expanded(child: Divider(color: Theme.of(context).dividerColor.withOpacity(0.05))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: () => setState(() => _showOthers = !_showOthers),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _showOthers ? 'Show Less' : 'More Options',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          _showOthers ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(child: Divider(color: Theme.of(context).dividerColor.withOpacity(0.05))),
            ],
          ),
        ),

        // Others Section (Animated)
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            children: widget.otherLocales.map((locale) {
              final isSelected = widget.state.locale.languageCode == locale.languageCode;
              return _LanguageOption(
                locale: locale,
                isSelected: isSelected,
                isSecondary: true,
                onTap: () {
                  context.read<LocaleCubit>().changeLocale(locale);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
          crossFadeState: _showOthers ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.locale,
    required this.isSelected,
    required this.onTap,
    this.isSecondary = false,
  });

  final Locale locale;
  final bool isSelected;
  final bool isSecondary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Row(
            children: [
              // Language icon
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary.withOpacity(0.12)
                      : isSecondary 
                          ? theme.scaffoldBackgroundColor.withOpacity(0.5)
                          : theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.dividerColor.withOpacity(0.08),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    _getEmoji(locale.languageCode),
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Language name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleState.getLanguageName(locale),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 16,
                        color: isSecondary && !isSelected 
                            ? theme.textTheme.bodyLarge?.color?.withOpacity(0.7)
                            : theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    if (!isSecondary || isSelected)
                      Text(
                        _getSubtitle(locale.languageCode),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                        ),
                      ),
                  ],
                ),
              ),

              // Selected indicator
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getEmoji(String code) {
    switch (code) {
      case 'en': return '🇺🇸';
      case 'tw': return '🇬🇭';
      case 'ar': return '🇸🇦';
      case 'fr': return '🇫🇷';
      default: return '🌐';
    }
  }

  String _getSubtitle(String code) {
    switch (code) {
      case 'en': return 'Native English';
      case 'tw': return 'Akan (Twi)';
      case 'ar': return 'Standard Arabic';
      case 'fr': return 'Standard French';
      default: return '';
    }
  }
}
