// lib/core/widgets/app_drawer.dart

import 'package:cap_project/app/view/app_router.dart';
import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_spacing.dart';
import 'package:cap_project/features/auth/cubit/cubit.dart';
import 'package:flutter/material.dart';

/// Clean, minimal navigation drawer - ChatGPT/Apple inspired
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            _buildCleanHeader(context),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                children: [
                  // Main Navigation
                  _buildNavItem(
                    context,
                    icon: Icons.chat_bubble_outline,
                    title: 'AI Chat',
                    route: AppRouter.chat,
                  ),

                  _buildNavItem(
                    context,
                    icon: Icons.camera_alt_outlined,
                    title: 'Med Scanner',
                    route: AppRouter.scanner,
                  ),

                  _buildNavItem(
                    context,
                    icon: Icons.forum_outlined,
                    title: 'Community',
                    route: AppRouter.forum,
                  ),

                  const Divider(height: 32),

                  // Settings
                  _buildNavItem(
                    context,
                    icon: Icons.language,
                    title: 'Language',
                    onTap: () {
                      Navigator.pop(context);
                      _showLanguageDialog(context);
                    },
                  ),

                  _buildNavItem(
                    context,
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {
                      Navigator.pop(context);
                      _showAboutDialog(context);
                    },
                  ),
                ],
              ),
            ),

            // Bottom Section
            const Divider(height: 1),
            _buildSignOutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCleanHeader(BuildContext context) {
    // Try to get auth state if available
    AuthUser? user;
    try {
      final authCubit = context.read<AuthCubit>();
      user = authCubit.state.user;
    } catch (e) {
      user = null;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xxl + 16, // Account for status bar
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Simple avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.accentPrimary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline,
              size: 24,
              color: AppColors.accentPrimary,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'Guest',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user?.email ?? 'Not signed in',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        String? route,
        VoidCallback? onTap,
      }) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final isSelected = route != null && currentRoute == route;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 4,
      ),
      leading: Icon(
        icon,
        size: 22,
        color: isSelected ? AppColors.accentPrimary : Colors.grey.shade700,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? Colors.black87 : Colors.grey.shade800,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.accentPrimary.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      onTap: onTap ??
              () {
            Navigator.pop(context);
            if (route != null && !isSelected) {
              AppRouter.replaceTo(context, route);
            }
          },
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              Navigator.pop(context);

              final shouldSignOut = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Sign Out'),
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
            icon: Icon(
              Icons.logout,
              size: 18,
              color: Colors.grey.shade700,
            ),
            label: Text(
              'Sign Out',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Language'),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(context, '🇬🇧', 'English', true),
            _buildLanguageOption(context, '🇪🇸', 'Español', false),
            _buildLanguageOption(context, '🇫🇷', 'Français', false),
            _buildLanguageOption(context, '🇩🇪', 'Deutsch', false),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
      BuildContext context,
      String flag,
      String language,
      bool isSelected,
      ) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(language),
      trailing: isSelected
          ? Icon(Icons.check, color: AppColors.accentPrimary, size: 20)
          : null,
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isSelected ? 'Already using $language' : '$language coming soon',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'MedBot',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.accentPrimary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.medical_services,
          size: 32,
          color: AppColors.accentPrimary,
        ),
      ),
      children: [
        const SizedBox(height: 16),
        const Text(
          'Your AI-powered medical information assistant.',
          style: TextStyle(fontSize: 15),
        ),
        const SizedBox(height: 12),
        Text(
          'MedBot helps expecting mothers, healthcare providers, '
              'and caregivers access reliable medical information.',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
      ],
    );
  }
}