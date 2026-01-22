import 'package:cap_project/app/view/app_router.dart';
import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';
import 'package:cap_project/features/auth/cubit/cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.backgroundPrimary,
        border: Border(
          right: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNavSection('LIBRARY'),
                    _buildNavItem(
                      context,
                      label: 'New Thread',
                      icon: Icons.add_rounded,
                      route: AppRouter.chat,
                      isPrimary: true,
                    ),
                     _buildNavItem(
                      context,
                      label: 'History',
                      icon: null, // Text only for secondary items if possible, or very subtle icon
                      onTap: () => _showComingSoon(context, 'History'),
                    ),
                    const SizedBox(height: 24),
                    _buildNavSection('DISCOVER'),
                     _buildNavItem(
                      context,
                      label: 'Med Scanner',
                      icon: null,
                      route: AppRouter.scanner,
                    ),
                    _buildNavItem(
                      context,
                      label: 'Community',
                      icon: null,
                      route: AppRouter.forum,
                    ),
                    const SizedBox(height: 24),
                    _buildNavSection('SETTINGS'),
                    _buildNavItem(
                      context,
                      label: 'Preferences',
                      icon: null,
                      onTap: () => _showComingSoon(context, 'Preferences'),
                    ),
                  ],
                ),
              ),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        'Thanzi',
        style: AppTextStyles.headlineMedium.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildNavSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 12),
      child: Text(
        title,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textTertiary,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required String label,
    IconData? icon,
    String? route,
    VoidCallback? onTap,
    bool isPrimary = false,
  }) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final isSelected = route != null && currentRoute == route;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () {
          if (Scaffold.of(context).hasDrawer && Scaffold.of(context).isDrawerOpen) {
             Navigator.pop(context);
          }
          if (route != null && !isSelected) {
            AppRouter.replaceTo(context, route);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.backgroundElevated : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected ? Border.all(color: AppColors.borderLight, width: 1.0) : null,
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 20,
                  color: isPrimary ? AppColors.accentPrimary : (isSelected ? AppColors.textPrimary : AppColors.textSecondary),
                ),
                const SizedBox(width: 12),
              ],
              Text(
                label,
                style: isPrimary 
                  ? AppTextStyles.labelLarge.copyWith(color: AppColors.accentPrimary, fontWeight: FontWeight.w700)
                  : AppTextStyles.bodyMedium.copyWith(
                      color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final user = context.watch<AuthCubit>().state.user;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.gray200,
            child: Text(
              (user?.displayName ?? 'U')[0].toUpperCase(),
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'User',
                  style: AppTextStyles.labelMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Free Plan', // Placeholder for "Plan" status common in Perplexity/NotebookLM
                  style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 18),
            onPressed: () {
               // Show settings or logout options
               _showSignOutDialog(context);
            },
            color: AppColors.textSecondary,
          )
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
             onPressed: () {
               Navigator.pop(context);
               context.read<AuthCubit>().signOut();
               AppRouter.replaceTo(context, AppRouter.auth);
             },
             child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature coming soon'), backgroundColor: AppColors.textPrimary),
    );
  }
}
