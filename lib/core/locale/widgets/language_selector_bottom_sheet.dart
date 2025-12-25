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
      decoration: const BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                'Select Language',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Language options
            BlocBuilder<LocaleCubit, LocaleState>(
              builder: (context, state) {
                return Column(
                  children: LocaleState.supportedLocales.map((locale) {
                    final isSelected = state.locale.languageCode == locale.languageCode;
                    return _LanguageOption(
                      locale: locale,
                      isSelected: isSelected,
                      onTap: () {
                        context.read<LocaleCubit>().changeLocale(locale);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
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

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.locale,
    required this.isSelected,
    required this.onTap,
  });

  final Locale locale;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              // Language icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accentPrimary.withOpacity(0.15)
                      : AppColors.backgroundPrimary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.accentPrimary
                        : AppColors.borderLight,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Icon(
                  LocaleState.getLanguageIcon(locale),
                  color: isSelected
                      ? AppColors.accentPrimary
                      : AppColors.textSecondary,
                  size: 20,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Language name
              Expanded(
                child: Text(
                  LocaleState.getLanguageName(locale),
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 17,
                  ),
                ),
              ),
              
              // Selected indicator
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.accentPrimary,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
