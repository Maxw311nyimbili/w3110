import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:landing_repository/landing_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/cubit/cubit.dart';

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
      final status = await context.read<LandingRepository>().getOnboardingStatus();
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final user = context.watch<AuthCubit>().state.user;
    final status = _onboardingStatus; // Changed from widget.onboardingStatus as ProfilePage doesn't have it
    final initial = (status?.userName ?? user?.displayName ?? 'U')[0].toUpperCase();
    final photoUrl = user?.photoUrl;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: const Text('Account Info'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSurface,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.borderLight, width: 1),
                      image: photoUrl != null 
                        ? DecorationImage(image: NetworkImage(photoUrl), fit: BoxFit.cover)
                        : null,
                    ),
                    child: photoUrl == null 
                      ? Center(
                          child: Text(
                            initial,
                            style: AppTextStyles.displayMedium.copyWith(
                              color: AppColors.accentPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      : null,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  status?.userName ?? user?.displayName ?? 'User',
                  style: AppTextStyles.headlineSmall,
                ),
                Text(
                  user?.email ?? '',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          
          _buildSectionHeader('PROFILE RELEVANCE'),
          _buildInfoItem('Account Nickname', status?.accountNickname ?? 'Personal'),
          _buildInfoItem('Primary Role', status?.userRole?.replaceAll('_', ' ').toUpperCase() ?? 'NOT SET'),
          
          if (status?.interests.isNotEmpty ?? false) ...[
            const SizedBox(height: 24),
            _buildSectionHeader('TOPICS OF INTEREST'),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: status!.interests.map((interest) {
                return Chip(
                  label: Text(interest[0].toUpperCase() + interest.substring(1)),
                  backgroundColor: AppColors.backgroundElevated,
                  labelStyle: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.borderLight),
                  ),
                );
              }).toList(),
            ),
          ],
          
          const SizedBox(height: 48),
          Center(
            child: Text(
              'This information is used to personalize your AI responses.',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
            ),
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
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textTertiary,
          letterSpacing: 1.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          Text(value, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
