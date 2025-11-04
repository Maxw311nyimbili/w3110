// lib/core/widgets/app_drawer.dart
// PREMIUM DESIGN - MedLink Brand Navigation

import 'package:cap_project/app/view/app_router.dart';
import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_spacing.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';
import 'package:cap_project/features/auth/cubit/cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Premium navigation drawer - MedLink branded
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.backgroundPrimary,
      child: SafeArea(
        child: Column(
          children: [
            _buildPremiumHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                children: [
                  // Main Navigation Section
                  _buildSectionLabel('Navigate'),
                  _buildNavItem(
                    context,
                    icon: Icons.chat_bubble_outline,
                    title: 'AI Chat',
                    subtitle: 'Medical guidance',
                    route: AppRouter.chat,
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.camera_alt_outlined,
                    title: 'Med Scanner',
                    subtitle: 'Identify medications',
                    route: AppRouter.scanner,
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.forum_outlined,
                    title: 'Community',
                    subtitle: 'Discussions & support',
                    route: AppRouter.forum,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Divider(height: 1, color: AppColors.gray200),
                  const SizedBox(height: AppSpacing.lg),
                  // Settings Section
                  _buildSectionLabel('Settings'),
                  _buildNavItem(
                    context,
                    icon: Icons.language_outlined,
                    title: 'Language',
                    subtitle: 'English',
                    onTap: () {
                      Navigator.pop(context);
                      _showLanguageDialog(context);
                    },
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    subtitle: 'Manage alerts',
                    onTap: () {
                      Navigator.pop(context);
                      _showComingSoon(context, 'Notifications');
                    },
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.help_outline_rounded,
                    title: 'Help & Support',
                    subtitle: 'FAQ & contact',
                    onTap: () {
                      Navigator.pop(context);
                      _showAboutDialog(context);
                    },
                  ),
                ],
              ),
            ),
            // Footer
            const Divider(height: 1, color: AppColors.gray200),
            _buildSignOutButton(context),
          ],
        ),
      ),
    );
  }

  /// Premium header with user info and branding
  Widget _buildPremiumHeader(BuildContext context) {
    AuthUser? user;
    try {
      final authCubit = context.read<AuthCubit>();
      user = authCubit.state.user;
    } catch (e) {
      user = null;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.gray200,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // MedLink branding
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accentPrimary,
                      AppColors.accentPrimary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentPrimary.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.medical_services_outlined,
                    size: 22,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MedLink',
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Health Companion',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // User info
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.backgroundElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.gray200,
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.accentLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      (user?.displayName ?? 'U')[0].toUpperCase(),
                      style: TextStyle(
                        color: AppColors.accentPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? 'Guest User',
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.email ?? 'Not signed in',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Section label for drawer sections
  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.textTertiary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Premium navigation item with subtitle
  Widget _buildNavItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        String? subtitle,
        String? route,
        VoidCallback? onTap,
      }) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final isSelected = route != null && currentRoute == route;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.accentLight : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: isSelected
            ? Border.all(
          color: AppColors.accentPrimary.withOpacity(0.3),
          width: 1,
        )
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 6,
        ),
        leading: Icon(
          icon,
          size: 20,
          color: isSelected ? AppColors.accentPrimary : AppColors.textSecondary,
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.accentPrimary : AppColors.textPrimary,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
          subtitle,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textTertiary,
            fontSize: 11,
          ),
        )
            : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        onTap: onTap ??
                () {
              Navigator.pop(context);
              if (route != null && !isSelected) {
                AppRouter.replaceTo(context, route);
              }
            },
      ),
    );
  }

  /// Premium sign out button
  Widget _buildSignOutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () async {
            Navigator.pop(context);

            final shouldSignOut = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(
                  'Sign Out',
                  style: AppTextStyles.headlineMedium,
                ),
                content: Text(
                  'Are you sure you want to sign out?',
                  style: AppTextStyles.bodyMedium,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(
                      'Sign Out',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );

            if (shouldSignOut == true && context.mounted) {
              try {
                context.read<AuthCubit>().signOut();
              } catch (e) {
                print('⚠️ AuthCubit not available for sign out');
              }
              AppRouter.replaceTo(context, AppRouter.auth);
            }
          },
          icon: const Icon(Icons.logout_rounded, size: 18),
          label: Text(
            'Sign Out',
            style: AppTextStyles.labelLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentPrimary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  /// Language selection dialog
  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Language',
          style: AppTextStyles.headlineMedium,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(context, '🇬🇧', 'English', true),
            _buildLanguageOption(context, '🇪🇸', 'Español', false),
            _buildLanguageOption(context, '🇫🇷', 'Français', false),
            _buildLanguageOption(context, '🇩🇪', 'Deutsch', false),
            _buildLanguageOption(context, '🇵🇹', 'Português', false),
          ],
        ),
      ),
    );
  }

  /// Language option item
  Widget _buildLanguageOption(
      BuildContext context,
      String flag,
      String language,
      bool isSelected,
      ) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 22)),
      title: Text(
        language,
        style: AppTextStyles.bodyMedium.copyWith(
          color: isSelected ? AppColors.accentPrimary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      trailing: isSelected
          ? Icon(
        Icons.check_rounded,
        color: AppColors.accentPrimary,
        size: 20,
      )
          : null,
      onTap: () {
        Navigator.pop(context);
        if (!isSelected) {
          _showComingSoon(context, language);
        }
      },
    );
  }

  /// About dialog
  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'MedLink',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.accentPrimary,
              AppColors.accentPrimary.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.medical_services_outlined,
          size: 32,
          color: Colors.white,
        ),
      ),
      children: [
        const SizedBox(height: 16),
        Text(
          'Your trusted AI-powered medical information assistant.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'MedLink provides reliable health guidance for expectant mothers, healthcare providers, and caregivers. Always consult a healthcare professional for medical advice.',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.backgroundElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.gray200,
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Version 1.0.0',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '© 2025 MedLink. All rights reserved.',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Coming soon notification
  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$feature coming soon',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.accentPrimary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}