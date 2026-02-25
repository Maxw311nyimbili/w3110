// lib/core/widgets/side_menu.dart
// ChatGPT / Claude / Perplexity–style sidebar — same nav items, improved design

import 'package:cap_project/app/cubit/navigation_cubit.dart';
import 'package:cap_project/app/view/app_router.dart';
import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';
import 'package:cap_project/features/auth/cubit/cubit.dart';
import 'package:cap_project/features/landing/widgets/welcome_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final sidebarBg = isDark
        ? AppColors.darkBackgroundSurface
        : const Color(0xFFF0F2F5);

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: sidebarBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            Expanded(
              child: _buildNavList(context),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.brandDarkTeal,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Center(
              child: Text(
                'T',
                style: AppTextStyles.labelLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Thanzi',
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).textTheme.bodyLarge?.color,
              letterSpacing: -0.4,
            ),
          ),
          const Spacer(),
          // Close button
          IconButton(
            icon: Icon(
              Icons.close_rounded,
              size: 18,
              color: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.color
                  ?.withOpacity(0.4),
            ),
            onPressed: () =>
                context.read<NavigationCubit>().toggleSidebar(),
            tooltip: 'Close',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  // ── Nav items ─────────────────────────────────────────────────────────────
  Widget _buildNavList(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _NavSection(label: 'Library'),
          _NavItem(
            icon: Icons.add_rounded,
            label: 'New Thread',
            route: AppRouter.chat,
            isPrimary: true,
          ),
          _NavItem(
            icon: Icons.history_rounded,
            label: 'History',
            onTap: () => _showComingSoon(context, 'History'),
          ),
          const SizedBox(height: 8),
          _NavSection(label: 'Discover'),
          _NavItem(
            icon: Icons.document_scanner_outlined,
            label: 'Med Scanner',
            route: AppRouter.scanner,
          ),
          _NavItem(
            icon: Icons.forum_outlined,
            label: 'Community',
            route: AppRouter.forum,
          ),
          const SizedBox(height: 8),
          _NavSection(label: 'Settings'),
          _NavItem(
            icon: Icons.tune_outlined,
            label: 'Preferences',
            route: AppRouter.settings,
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

  // ── Footer ────────────────────────────────────────────────────────────────
  Widget _buildFooter(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final user = authState.user;
    final isAuthenticated = authState.status == AuthStatus.authenticated;

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: isAuthenticated
          ? _AuthFooter(user: user, context: context)
          : _GuestFooter(context: context),
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _NavSection extends StatelessWidget {
  const _NavSection({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.color
                  ?.withOpacity(0.45),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.9,
              fontSize: 10,
            ),
      ),
    );
  }
}

// ─── Nav item ─────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    this.route,
    this.onTap,
    this.isPrimary = false,
  });

  final IconData icon;
  final String label;
  final String? route;
  final VoidCallback? onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final isSelected = route != null && currentRoute == route;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final mutedColor =
        Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.75);
    final primaryColor = Theme.of(context).colorScheme.primary;

    Color iconColor;
    Color labelColor;
    FontWeight labelWeight;

    if (isPrimary) {
      iconColor = primaryColor;
      labelColor = primaryColor;
      labelWeight = FontWeight.w700;
    } else if (isSelected) {
      iconColor = AppColors.brandDarkTeal;
      labelColor = textColor ?? AppColors.textPrimary;
      labelWeight = FontWeight.w600;
    } else {
      iconColor = mutedColor ?? AppColors.textSecondary;
      labelColor = mutedColor ?? AppColors.textSecondary;
      labelWeight = FontWeight.w400;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      child: InkWell(
        onTap: onTap ??
            () {
              if (route != null && !isSelected) {
                final scaffold = Scaffold.of(context);
                if (scaffold.hasDrawer && scaffold.isDrawerOpen) {
                  Navigator.pop(context);
                }
                AppRouter.replaceTo(context, route!);
              }
            },
        borderRadius: BorderRadius.circular(8),
        hoverColor: AppColors.brandDarkTeal.withOpacity(0.06),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.brandDarkTeal.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: labelColor,
                    fontWeight: labelWeight,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isSelected)
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.brandDarkTeal,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Authenticated footer ─────────────────────────────────────────────────────

class _AuthFooter extends StatelessWidget {
  const _AuthFooter({required this.user, required this.context});
  final dynamic user;
  final BuildContext context;

  void _showSignOutDialog(BuildContext ctx) {
    showDialog<void>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ctx.read<AuthCubit>().signOut();
              AppRouter.replaceTo(ctx, AppRouter.splash);
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext buildContext) {
    final name = (user?.displayName as String?) ?? 'User';
    final initials = name
        .trim()
        .split(' ')
        .take(2)
        .map((p) => p.isEmpty ? '' : p[0].toUpperCase())
        .join();

    return InkWell(
      onTap: () => _showSignOutDialog(buildContext),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.brandDarkTeal.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.brandDarkTeal.withOpacity(0.3),
                ),
              ),
              child: Center(
                child: Text(
                  initials.isEmpty ? 'U' : initials,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.brandDarkTeal,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: Theme.of(buildContext).textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Free Plan',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Theme.of(buildContext)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withOpacity(0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.more_horiz_rounded,
              size: 18,
              color: Theme.of(buildContext)
                  .textTheme
                  .bodySmall
                  ?.color
                  ?.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Guest footer ─────────────────────────────────────────────────────────────

class _GuestFooter extends StatelessWidget {
  const _GuestFooter({required this.context});
  final BuildContext context;

  @override
  Widget build(BuildContext buildContext) {
    return InkWell(
      onTap: () => WelcomeDrawer.show(buildContext),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Theme.of(buildContext).colorScheme.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_outline_rounded,
                size: 18,
                color: Theme.of(buildContext).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Sign In',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.brandDarkTeal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Access your account',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Theme.of(buildContext)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withOpacity(0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: AppColors.brandDarkTeal.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }
}
