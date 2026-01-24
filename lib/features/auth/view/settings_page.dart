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
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Custom Header with big title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      l10n.settings,
                      style: AppTextStyles.displaySmall.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // --- Preferences Section ---
                    _buildSectionHeader(l10n.preferences),
                    _buildGroup([
                      BlocBuilder<LocaleCubit, LocaleState>(
                        builder: (context, state) {
                          return _buildSettingTile(
                            title: l10n.language,
                            subtitle: LocaleState.getLanguageName(state.locale),
                            icon: Icons.language_rounded,
                            showDivider: true,
                            onTap: () =>
                                LanguageSelectorBottomSheet.show(context),
                          );
                        },
                      ),
                      _buildSettingTile(
                        title: l10n.darkMode,
                        subtitle: l10n.systemDefault,
                        icon: Icons.dark_mode_outlined,
                        onTap: () {}, // TODO: Implement ThemeCubit
                      ),
                    ]),
                    const SizedBox(height: 32),

                    // --- Profile Section ---
                    _buildSectionHeader(l10n.profile),
                    _buildGroup([
                      _buildSettingTile(
                        title: l10n.accountInfo,
                        icon: Icons.person_outline_rounded,
                        showDivider: true,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ProfilePage()),
                        ),
                      ),
                      _buildSettingTile(
                        title: 'Push Notifications',
                        icon: Icons.notifications_outlined,
                        showDivider: true,
                        onTap: () {},
                      ),
                      _buildSettingTile(
                        title: l10n.signOut,
                        icon: Icons.logout_rounded,
                        textColor: AppColors.error,
                        isDestructive: true,
                        onTap: () => _handleLogout(context, l10n),
                      ),
                    ]),
                    const SizedBox(height: 32),

                    // --- About Section ---
                    _buildSectionHeader(l10n.about),
                    _buildGroup([
                      _buildSettingTile(
                        title: l10n.privacyPolicy,
                        icon: Icons.privacy_tip_outlined,
                        showDivider: true,
                        onTap: () {},
                      ),
                      _buildSettingTile(
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
    );
  }

  Future<void> _handleLogout(BuildContext context, AppLocalizations l10n) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.signOut, style: AppTextStyles.headlineSmall),
        content: Text(
          'Are you sure you want to sign out?',
          style: AppTextStyles.bodyMedium, // Removed const
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              l10n.cancel,
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l10n.signOut,
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await context.read<AuthCubit>().signOut();
      if (context.mounted) {
        await context.read<LandingCubit>().resetOnboarding();
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRouter.landing,
          (route) => false,
        );
      }
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textTertiary,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight, width: 0.5),
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

  Widget _buildSettingTile({
    required String title,
    String? subtitle,
    required IconData icon,
    VoidCallback? onTap,
    Color? textColor,
    bool showDivider = false,
    bool isDestructive = false,
  }) {
    // Determine visuals based on state
    final color = isDestructive ? AppColors.error : (textColor ?? AppColors.accentPrimary);
    
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
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: isDestructive ? AppColors.error : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textTertiary,
                            ),
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
            color: AppColors.borderLight.withOpacity(0.5),
          ),
      ],
    );
  }
}
