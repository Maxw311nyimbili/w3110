import 'package:flutter/material.dart';
import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => const SettingsPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionHeader('PREFERENCES'),
          _buildSettingTile(
            title: 'Language',
            subtitle: 'English (US)',
            icon: Icons.language_rounded,
            onTap: () {
              // Show language picker
            },
          ),
          _buildSettingTile(
            title: 'Dark Mode',
            subtitle: 'System Default',
            icon: Icons.dark_mode_outlined,
            onTap: () {},
          ),
          const SizedBox(height: 32),
          _buildSectionHeader('PROFILE'),
          _buildSettingTile(
            title: 'Account Info',
            icon: Icons.person_outline_rounded,
            onTap: () {},
          ),
          _buildSettingTile(
            title: 'Sign Out',
            icon: Icons.logout_rounded,
            textColor: AppColors.error,
            onTap: () {
              // Handle sign out
            },
          ),
          const SizedBox(height: 32),
          _buildSectionHeader('ABOUT'),
          _buildSettingTile(
            title: 'Privacy Policy',
            icon: Icons.privacy_tip_outlined,
            onTap: () {},
          ),
          _buildSettingTile(
            title: 'Version',
            subtitle: '1.0.0 (Thanzi Build)',
            icon: Icons.info_outline_rounded,
            onTap: null,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textTertiary,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.backgroundSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight, width: 0.5),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: textColor ?? AppColors.textSecondary),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: textColor ?? AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: AppColors.textTertiary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
