import 'package:cap_project/app/cubit/navigation_cubit.dart';
import 'package:cap_project/app/view/app_router.dart';
import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';
import 'package:cap_project/features/auth/cubit/cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cap_project/core/widgets/brand_logo.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (context, navState) {
        final isCollapsed = navState.isSidebarCollapsed;

        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(
              right: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, isCollapsed),
                const SizedBox(height: 32),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isCollapsed ? 8 : 16,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          isCollapsed
                              ? CrossAxisAlignment.center
                              : CrossAxisAlignment.start,
                      children: [
                        if (!isCollapsed) ...[
                          _buildNavSection(context, 'LIBRARY'),
                        ],
                        _buildNavItem(
                          context,
                          label: 'New Thread',
                          icon: Icons.add_rounded,
                          route: AppRouter.chat,
                          isPrimary: true,
                          isCollapsed: isCollapsed,
                        ),
                        _buildNavItem(
                          context,
                          label: 'History',
                          icon: Icons.history_rounded,
                          onTap: () => _showComingSoon(context, 'History'),
                          isCollapsed: isCollapsed,
                        ),
                        const SizedBox(height: 24),
                        if (!isCollapsed) ...[
                          _buildNavSection(context, 'DISCOVER'),
                        ],
                        _buildNavItem(
                          context,
                          label: 'Med Scanner',
                          icon: Icons.document_scanner_rounded,
                          route: AppRouter.scanner,
                          isCollapsed: isCollapsed,
                        ),
                        _buildNavItem(
                          context,
                          label: 'Community',
                          icon: Icons.forum_rounded,
                          route: AppRouter.forum,
                          isCollapsed: isCollapsed,
                        ),
                        const SizedBox(height: 24),
                        if (!isCollapsed) ...[
                          _buildNavSection(context, 'SETTINGS'),
                        ],
                        _buildNavItem(
                          context,
                          label: 'Preferences',
                          icon: Icons.tune_rounded,
                          route: AppRouter.settings,
                          isCollapsed: isCollapsed,
                        ),
                      ],
                    ),
                  ),
                ),
                _buildFooter(context, isCollapsed),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isCollapsed) {
    if (isCollapsed) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: BrandLogo(size: 32, isBreathing: false),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        'Thanzi',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: Theme.of(context).textTheme.bodyLarge?.color,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildNavSection(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
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
    required bool isCollapsed,
  }) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final isSelected = route != null && currentRoute == route;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap:
            onTap ??
            () {
              if (route != null && !isSelected) {
                final scaffold = Scaffold.of(context);
                final hasDrawer = scaffold.hasDrawer;
                final isDrawerOpen = scaffold.isDrawerOpen;

                if (hasDrawer && isDrawerOpen) {
                  Navigator.pop(context);
                }

                AppRouter.replaceTo(context, route);
              }
            },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    width: 1.0,
                  )
                : null,
          ),
          child: Row(
            mainAxisAlignment:
                isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 20,
                  color: isPrimary
                      ? Theme.of(context).colorScheme.primary
                      : (isSelected
                            ? Theme.of(context).textTheme.bodyLarge?.color
                            : Theme.of(context).textTheme.bodySmall?.color),
                ),
                if (!isCollapsed) const SizedBox(width: 12),
              ],
              if (!isCollapsed)
                Expanded(
                  child: Text(
                    label,
                    style: isPrimary
                        ? Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          )
                        : Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isSelected
                                ? Theme.of(context).textTheme.bodyLarge?.color
                                : Theme.of(context).textTheme.bodySmall?.color,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
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
      SnackBar(
        content: Text('$feature coming soon'),
        backgroundColor: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isCollapsed) {
    final authState = context.watch<AuthCubit>().state;
    final user = authState.user;
    final isAuthenticated = authState.status == AuthStatus.authenticated;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
        ),
      ),
      child: isAuthenticated
          ? Row(
              mainAxisAlignment:
                  isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                  child: Text(
                    (user?.displayName ?? 'U')[0].toUpperCase(),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                  ),
                ),
                if (!isCollapsed) ...[
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
                          'Free Plan',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color
                                    ?.withOpacity(0.6),
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    onPressed: () => _showSignOutDialog(context),
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    tooltip: 'Sign Out',
                  ),
                ],
              ],
            )
          : InkWell(
              onTap: () => AppRouter.navigateTo(context, AppRouter.auth),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: isCollapsed
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.login_rounded,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    if (!isCollapsed) ...[
                      const SizedBox(width: 12),
                      Text(
                        'Sign In',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
