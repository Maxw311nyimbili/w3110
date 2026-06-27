import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/l10n.dart';
import '../cubit/cubit.dart';
import 'package:cap_project/core/widgets/premium_button.dart';
import 'package:cap_project/core/widgets/glass_card.dart';

class RoleSelectionStep extends StatelessWidget {
  const RoleSelectionStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LandingCubit, LandingState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              color: Theme.of(context).textTheme.bodyLarge?.color,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    builder: (context, value, _) => Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 12 * (1 - value)),
                        child: Text(
                          AppLocalizations.of(context).selectYourRole,
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).textTheme.displayLarge?.color,
                                letterSpacing: -1.0,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildRoleItem(
                          context,
                          AppLocalizations.of(context).roleMother,
                          UserRole.mother,
                          state,
                          'I am expecting or have children',
                          index: 0,
                        ),
                        _buildRoleItem(
                          context,
                          AppLocalizations.of(context).roleSupportPartner,
                          UserRole.supportPartner,
                          state,
                          'I am supporting a mother',
                          index: 1,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(height: 1),
                        ),
                        _buildRoleItem(
                          context,
                          AppLocalizations.of(context).roleDoctor,
                          UserRole.doctor,
                          state,
                          AppLocalizations.of(context).roleDoctorSubtitle,
                          isProfessional: true,
                          index: 2,
                        ),
                        _buildRoleItem(
                          context,
                          AppLocalizations.of(context).roleMidwife,
                          UserRole.midwife,
                          state,
                          AppLocalizations.of(context).roleMidwifeSubtitle,
                          isProfessional: true,
                          index: 3,
                        ),
                        _buildRoleItem(
                          context,
                          AppLocalizations.of(context).roleClinician,
                          UserRole.clinician,
                          state,
                          AppLocalizations.of(context).roleClinicianSubtitle,
                          isProfessional: true,
                          index: 4,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: PremiumButton(
                      onPressed: state.canProceed
                          ? () => context.read<LandingCubit>().nextStep()
                          : null,
                      text: AppLocalizations.of(context).continueButton,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoleItem(
    BuildContext context,
    String title,
    UserRole role,
    LandingState state,
    String subtitle, {
    bool isProfessional = false,
    required int index,
  }) {
    final isSelected = state.selectedRole == role;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 250 + (index * 40)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: InkWell(
          onTap: () => context.read<LandingCubit>().selectRole(role),
          borderRadius: BorderRadius.circular(24),
          child: AnimatedScale(
            scale: isSelected ? 1.02 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: GlassCard(
              padding: const EdgeInsets.all(20),
              borderRadius: 24,
              borderOpacity: isSelected ? 0.6 : 0.2,
              tintOpacity: isSelected ? 0.88 : 0.72,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              title,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(
                                            context,
                                          ).textTheme.bodyLarge?.color,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.color,
                                fontSize: 14,
                                height: 1.4,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).dividerColor.withOpacity(0.3),
                        width: 2,
                      ),
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
