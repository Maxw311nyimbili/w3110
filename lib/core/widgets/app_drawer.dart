import 'package:cap_project/app/view/app_router.dart';
import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_spacing.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';
import 'package:cap_project/features/auth/cubit/cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.backgroundPrimary,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildSectionLabel('CHAT'),
                  _buildNavItem(
                    context,
                    icon: Icons.add_rounded,
                    label: 'New Chat',
                    route: AppRouter.chat,
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.history_rounded,
                    label: 'History',
                    onTap: () {
                      Navigator.pop(context);
                      _showComingSoon(context, 'History');
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildSectionLabel('FEATURES'),
                  _buildNavItem(
                    context,
                    icon: Icons.camera_alt_outlined,
                    label: 'Med Scanner',
                    route: AppRouter.scanner,
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.forum_outlined,
                    label: 'Community',
                    route: AppRouter.forum,
                  ),
                  const SizedBox(height: 20),
                  _buildSectionLabel('SETTINGS'),
                  _buildNavItem(
                    context,
                    icon: Icons.settings_outlined,
                    label: 'Preferences',
                    onTap: () {
                      Navigator.pop(context);
                      _showComingSoon(context, 'Preferences');
                    },
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.help_outline_rounded,
                    label: 'Help & Support',
                    onTap: () {
                      Navigator.pop(context);
                      _showComingSoon(context, 'Help');
                    },
                  ),
                ],
              ),
            ),
            Divider(
              color: AppColors.gray200,
              height: 1,
              thickness: 0.5,
            ),
            _buildSignOutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    AuthUser? user;
    try {
      user = context.read<AuthCubit>().state.user;
    } catch (e) {
      user = null;
    }

    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accentPrimary,
                      AppColors.accentPrimary.withOpacity(0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(
                    Icons.medical_services_outlined,
                    size: 24,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MedLink',
                      style: AppTextStyles.headlineSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Health Companion',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
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
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.accentLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      (user?.displayName ?? 'U')[0].toUpperCase(),
                      style: TextStyle(
                        color: AppColors.accentPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? 'User',
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        user?.email ?? 'Not signed in',
                        style: AppTextStyles.caption.copyWith(
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

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textTertiary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, {
        required IconData icon,
        required String label,
        String? route,
        VoidCallback? onTap,
      }) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final isSelected = route != null && currentRoute == route;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () {
          Navigator.pop(context);
          if (route != null && !isSelected) {
            AppRouter.replaceTo(context, route);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isSelected ? AppColors.accentLight : Colors.transparent,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected
                      ? AppColors.accentPrimary
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isSelected
                        ? AppColors.accentPrimary
                        : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
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
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(
                      'Sign Out',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            );

            if (shouldSignOut == true && context.mounted) {
              context.read<AuthCubit>().signOut();
              AppRouter.replaceTo(context, AppRouter.auth);
            }
          },
          icon: const Icon(Icons.logout_rounded, size: 16),
          label: const Text('Sign Out'),
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

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon'),
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