import 'package:flutter/material.dart';
import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';
import 'package:cap_project/app/view/app_router.dart';
import 'package:cap_project/core/widgets/widgets.dart';

enum SelectedFeature {
  chat,
  forum,
  scanner,
}

class FeatureChoicePage extends StatefulWidget {
  const FeatureChoicePage({super.key});

  @override
  State<FeatureChoicePage> createState() => _FeatureChoicePageState();
}

class _FeatureChoicePageState extends State<FeatureChoicePage> {
  SelectedFeature? _selectedFeature;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Stack(
        children: [
          // Subtle Background Logo Identity - Static, Tilted, Large
          Positioned(
            right: -120,
            top: -60,
            child: Opacity(
              opacity: 0.04,
              child: Transform.rotate(
                angle: -0.35,
                child: const BrandLogo(
                  size: 560,
                  isBreathing: false,
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Premium Editorial Header
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SELECT INTENT',
                            style: AppTextStyles.labelSmall.copyWith(
                              letterSpacing: 3.0,
                              fontWeight: FontWeight.w800,
                              color: AppColors.accentPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'What are we focusing on today?',
                            style: AppTextStyles.displayMedium.copyWith(
                              color: AppColors.textPrimary,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),

                      // Feature Choice List - Unified Brand Teal Identity
                      _buildFeatureItem(
                        title: 'Clinical Support',
                        subtitle: 'Engage with AI diagnostics and tailored health advice.',
                        icon: Icons.auto_awesome_rounded,
                        color: AppColors.accentPrimary,
                        feature: SelectedFeature.chat,
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureItem(
                        title: 'Peer Network',
                        subtitle: 'Connect with local health communities and shared wisdom.',
                        icon: Icons.groups_2_rounded,
                        color: AppColors.accentPrimary,
                        feature: SelectedFeature.forum,
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureItem(
                        title: 'Rapid Validation',
                        subtitle: 'Scan and verify prescriptions with medical-grade precision.',
                        icon: Icons.qr_code_scanner_rounded,
                        color: AppColors.accentPrimary,
                        feature: SelectedFeature.scanner,
                      ),
                      
                      const SizedBox(height: 80),
                      
                      // Primary Navigation Action
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 300),
                          child: AppButton(
                            text: 'INITIALIZE EXPERIENCE',
                            onPressed: _selectedFeature != null
                                ? () => _navigateToFeature(context)
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required SelectedFeature feature,
  }) {
    final isSelected = _selectedFeature == feature;
    final baseColor = color;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedFeature = feature),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected 
              ? baseColor.withOpacity(0.08) 
              : baseColor.withOpacity(0.03),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? baseColor : baseColor.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: baseColor.withOpacity(0.12),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? baseColor : baseColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : baseColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToFeature(BuildContext context) {
    if (_selectedFeature == null) return;
    
    switch (_selectedFeature!) {
      case SelectedFeature.chat:
        AppRouter.navigateTo<void>(context, AppRouter.chat);
      case SelectedFeature.forum:
        AppRouter.navigateTo<void>(context, AppRouter.forum);
      case SelectedFeature.scanner:
        AppRouter.navigateTo<void>(context, AppRouter.scanner);
    }
  }
}
