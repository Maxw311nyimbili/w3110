import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';
import 'package:cap_project/features/auth/cubit/cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:landing_repository/landing_repository.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  OnboardingStatus? _onboardingStatus;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOnboarding();
  }

  Future<void> _loadOnboarding() async {
    try {
      final status =
          await context.read<LandingRepository>().getOnboardingStatus();
      if (mounted) {
        setState(() {
          _onboardingStatus = status;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If loading, show a loading screen or skeleton
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final user = context.watch<AuthCubit>().state.user;
    final status = _onboardingStatus;
    // Fallback initials
    final displayName = status?.userName ?? user?.displayName ?? 'User';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';
    final photoUrl = user?.photoUrl;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Custom Header with Back Button and Large Avatar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  children: [
                    // Top Bar
                    Row(
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
                        const Spacer(),
                        // Could add an 'Edit' button here later
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Avatar
                    Container(
                      width: 120,
                      height: 120,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSurface,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.borderLight.withOpacity(0.5)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.accentPrimary.withOpacity(0.1),
                          shape: BoxShape.circle,
                          image: photoUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(photoUrl),
                                  fit: BoxFit.cover)
                              : null,
                        ),
                        child: photoUrl == null
                            ? Center(
                                child: Text(
                                  initial,
                                  style: AppTextStyles.displayMedium.copyWith(
                                    color: AppColors.accentPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 48,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Name & Badge
                    Text(
                      displayName,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.displaySmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.accentPrimary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status?.userRole?.replaceAll('_', ' ').toUpperCase() ??
                            'MEMBER',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),

            // Info Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Personal Information Group
                    _buildSectionHeader('PERSONAL INFORMATION'),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSurface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: AppColors.borderLight, width: 0.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            icon: Icons.alternate_email_rounded,
                            label: 'Email',
                            value: user?.email ?? 'No email set',
                            showDivider: true,
                          ),
                          _buildInfoRow(
                            icon: Icons.tag_rounded,
                            label: 'Account Nickname',
                            value: status?.accountNickname ?? 'Personal',
                            showDivider: false,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Interests Section
                    if (status?.interests.isNotEmpty ?? false) ...[
                      _buildSectionHeader('INTERESTS'),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: status!.interests.map((interest) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundElevated,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: AppColors.borderLight),
                              ),
                              child: Text(
                                interest[0].toUpperCase() + interest.substring(1),
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 48),
                    ],

                    // Footer
                    Text(
                      'Member since ${DateTime.now().year}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
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

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool showDivider = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.backgroundPrimary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: AppColors.accentPrimary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
