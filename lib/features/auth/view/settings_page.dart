import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cap_project/core/locale/cubit/locale_cubit.dart';
import 'package:cap_project/core/locale/cubit/locale_state.dart';
import 'package:cap_project/core/locale/widgets/language_selector_bottom_sheet.dart';
import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';
import 'package:cap_project/l10n/l10n.dart';
import 'package:cap_project/features/auth/view/profile_page.dart';
import 'package:cap_project/features/auth/cubit/auth_cubit.dart';
import 'package:cap_project/features/landing/cubit/landing_cubit.dart';
import 'package:cap_project/app/view/app_router.dart';

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
      appBar: AppBar(
        title: Text(l10n.settings),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          _buildSectionHeader(l10n.preferences),
          _buildGroup([
            BlocBuilder<LocaleCubit, LocaleState>(
              builder: (context, state) {
                return _buildSettingTile(
                  title: l10n.language,
                  subtitle: LocaleState.getLanguageName(state.locale),
                  icon: Icons.language_rounded,
                  showDivider: true,
                  onTap: () => LanguageSelectorBottomSheet.show(context),
                );
              },
            ),
            _buildSettingTile(
              title: l10n.darkMode,
              subtitle: l10n.systemDefault,
              icon: Icons.dark_mode_outlined,
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 32),
          _buildSectionHeader(l10n.profile),
          _buildGroup([
            _buildSettingTile(
              title: l10n.accountInfo,
              icon: Icons.person_outline_rounded,
              showDivider: true,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              ),
            ),
            _buildSettingTile(
              title: l10n.signOut,
              icon: Icons.logout_rounded,
              textColor: AppColors.error,
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(l10n.signOut),
                    content: Text('Are you sure you want to sign out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(l10n.cancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(
                          l10n.signOut, 
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirm == true && context.mounted) {
                  // 1. Sign out from AuthCubit
                  await context.read<AuthCubit>().signOut();
                  
                  // 2. Clear LandingCubit (if using demo mode or just resetting)
                  if (context.mounted) {
                    await context.read<LandingCubit>().resetOnboarding();
                    
                    // 3. Navigate to Landing Page (Root)
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRouter.landing, 
                      (route) => false,
                    );
                  }
                }
              },
            ),
          ]),
          const SizedBox(height: 32),
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
              onTap: null,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 16),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textTertiary,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          fontSize: 11,
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
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
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
  }) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: (textColor ?? AppColors.accentPrimary).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: (textColor ?? AppColors.accentPrimary).withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      icon, 
                      size: 18, 
                      color: textColor ?? AppColors.accentPrimary
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: textColor ?? AppColors.textPrimary,
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textTertiary,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (onTap != null)
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: AppColors.textTertiary,
                    ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            indent: 64,
            endIndent: 0,
            color: AppColors.borderLight,
          ),
      ],
    );
  }
}
