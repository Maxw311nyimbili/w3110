import 'package:cap_project/app/view/app_router.dart';
import 'package:cap_project/core/locale/cubit/locale_cubit.dart';
import 'package:cap_project/core/locale/cubit/locale_state.dart';
import 'package:cap_project/core/locale/widgets/language_selector_bottom_sheet.dart';
import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';
import 'package:cap_project/features/auth/cubit/auth_cubit.dart';
import 'package:cap_project/features/auth/view/profile_page.dart';
import 'package:cap_project/features/landing/cubit/landing_cubit.dart';
import 'package:cap_project/l10n/l10n.dart';
import 'package:cap_project/core/theme/cubit/theme_cubit.dart';
import 'package:cap_project/core/theme/cubit/theme_state.dart';
import 'package:cap_project/core/util/responsive_utils.dart';
import 'package:cap_project/core/widgets/main_navigation_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cap_project/core/widgets/entry_animation.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => const SettingsPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return MainNavigationShell(
      title: Text(
        l10n.settings,
        style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 24,
            ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    children: [
                      // --- Preferences Section ---
                      _buildSectionHeader(context, l10n.preferences),
                      _buildGroup(context, [
                        BlocBuilder<LocaleCubit, LocaleState>(
                          builder: (context, state) {
                            return _buildSettingTile(
                              context,
                              title: l10n.language,
                              subtitle: LocaleState.getLanguageName(
                                state.locale,
                              ),
                              icon: Icons.language_rounded,
                              showDivider: true,
                              onTap: () =>
                                  LanguageSelectorBottomSheet.show(context),
                            );
                          },
                        ),
                        BlocBuilder<ThemeCubit, ThemeState>(
                          builder: (context, state) {
                            String subtitle;
                            switch (state.themeMode) {
                              case AppThemeMode.light:
                                subtitle = 'Light';
                                break;
                              case AppThemeMode.dark:
                                subtitle = 'Dark';
                                break;
                              case AppThemeMode.system:
                                subtitle = l10n.systemDefault;
                                break;
                            }

                            return _buildSettingTile(
                              context,
                              title: l10n.darkMode,
                              subtitle: subtitle,
                              icon: state.themeMode == AppThemeMode.dark
                                  ? Icons.dark_mode_rounded
                                  : Icons.dark_mode_outlined,
                              onTap: () => _showThemeSelector(context, l10n),
                            );
                          },
                        ),
                      ]),
                      const SizedBox(height: 32),

                      // --- Profile Section ---
                      _buildSectionHeader(context, l10n.profile),
                      _buildGroup(context, [
                        _buildSettingTile(
                          context,
                          title: l10n.accountInfo,
                          icon: Icons.person_outline_rounded,
                          showDivider: true,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfilePage(),
                            ),
                          ),
                        ),
                        _buildSettingTile(
                          context,
                          title: 'Push Notifications',
                          icon: Icons.notifications_outlined,
                          showDivider: true,
                          onTap: () {},
                        ),
                        _buildSettingTile(
                          context,
                          title: l10n.signOut,
                          icon: Icons.logout_rounded,
                          textColor: Theme.of(context).colorScheme.error,
                          isDestructive: true,
                          showDivider: true,
                          onTap: () => _handleLogout(context, l10n),
                        ),
                        _buildSettingTile(
                          context,
                          title: 'Reset App Data',
                          subtitle: 'Wipes all local state (Dev Only)',
                          icon: Icons.delete_forever_rounded,
                          textColor: Theme.of(context).colorScheme.error,
                          isDestructive: true,
                          onTap: () => _handleDeepReset(context),
                        ),
                      ]),
                      const SizedBox(height: 32),

                      // --- About Section ---
                      _buildSectionHeader(context, l10n.about),
                      _buildGroup(context, [
                        _buildSettingTile(
                          context,
                          title: l10n.privacyPolicy,
                          icon: Icons.privacy_tip_outlined,
                          showDivider: true,
                          onTap: () {},
                        ),
                        _buildSettingTile(
                          context,
                          title: l10n.version,
                          subtitle: l10n.versionNumber,
                          icon: Icons.info_outline_rounded,
                          onTap: null, // Just display
                        ),
                      ]),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.signOut, style: Theme.of(context).textTheme.headlineSmall),
        content: Text(
          'Are you sure you want to sign out?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              l10n.cancel,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l10n.signOut,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await context.read<AuthCubit>().signOut();
      if (context.mounted) {
        // We don't necessarily clear ALL local data on a simple sign out,
        // but we should at least reset the onboarding cubit's state
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRouter.landing,
          (route) => false,
        );
      }
    }
  }

  Future<void> _handleDeepReset(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Reset All Data?', style: Theme.of(context).textTheme.headlineSmall),
        content: Text(
          'This will permanently delete ALL local data, including your login session and onboarding progress. The app will restart from scratch.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Reset Everything',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      // 1. Clear Auth (Tokens)
      await context.read<AuthCubit>().signOut();
      if (context.mounted) {
        // 2. Clear Landing (Onboarding/Prefs)
        await context.read<LandingCubit>().resetOnboarding();
        // 3. Go to root
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRouter.landing,
          (route) => false,
        );
      }
    }
  }

  Future<void> _showThemeSelector(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final cubit = context.read<ThemeCubit>();
    
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.darkMode,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            _buildThemeOption(
              context,
              title: 'Light',
              icon: Icons.light_mode_outlined,
              isSelected: cubit.state.themeMode == AppThemeMode.light,
              onTap: () {
                cubit.setThemeMode(AppThemeMode.light);
                Navigator.pop(context);
              },
            ),
            _buildThemeOption(
              context,
              title: 'Dark',
              icon: Icons.dark_mode_outlined,
              isSelected: cubit.state.themeMode == AppThemeMode.dark,
              onTap: () {
                cubit.setThemeMode(AppThemeMode.dark);
                Navigator.pop(context);
              },
            ),
            _buildThemeOption(
              context,
              title: l10n.systemDefault,
              icon: Icons.settings_brightness_outlined,
              isSelected: cubit.state.themeMode == AppThemeMode.system,
              onTap: () {
                cubit.setThemeMode(AppThemeMode.system);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodySmall?.color,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyLarge?.color,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildGroup(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), // Slightly stronger shadow
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required String title,
    String? subtitle,
    required IconData icon,
    VoidCallback? onTap,
    Color? textColor,
    bool showDivider = false,
    bool isDestructive = false,
  }) {
    // Determine visuals based on state
    final color = isDestructive
        ? Theme.of(context).colorScheme.error
        : (textColor ?? Theme.of(context).colorScheme.primary);

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  // Icon container
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Chevron (only if tappable)
                  if (onTap != null)
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: AppColors.textTertiary.withOpacity(0.5),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 72, // Aligned with text start
            endIndent: 0,
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
      ],
    );
  }
}
