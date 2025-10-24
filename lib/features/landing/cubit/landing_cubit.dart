// lib/features/landing/cubit/landing_cubit.dart

import 'package:cap_project/features/landing/cubit/landing_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:landing_repository/landing_repository.dart';

/// Manages onboarding flow and user preferences
class LandingCubit extends Cubit<LandingState> {
  LandingCubit({
    required LandingRepository landingRepository,
  })  : _landingRepository = landingRepository,
        super(const LandingState());

  final LandingRepository _landingRepository;

  /// Initialize - check if onboarding already completed
  Future<void> initialize() async {
    try {
      emit(state.copyWith(isLoading: true));

      final status = await _landingRepository.getOnboardingStatus();

      if (status.isComplete) {
        emit(state.copyWith(
          currentStep: OnboardingStep.complete,
          selectedRole: _mapStringToRole(status.userRole),
          consentGiven: status.consentGiven,
          consentVersion: status.consentVersion,
          isLoading: false,
        ));
      } else {
        emit(state.copyWith(isLoading: false));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load onboarding status',
      ));
    }
  }

  /// Move to next onboarding step
  void nextStep() {
    if (!state.canProceed) return;

    final nextStep = _getNextStep(state.currentStep);
    emit(state.copyWith(currentStep: nextStep));
  }

  /// Move to previous onboarding step
  void previousStep() {
    final previousStep = _getPreviousStep(state.currentStep);
    if (previousStep != null) {
      emit(state.copyWith(currentStep: previousStep));
    }
  }

  /// Skip optional steps
  void skipStep() {
    if (state.currentStep == OnboardingStep.contextGathering) {
      emit(state.copyWith(currentStep: OnboardingStep.consent));
    }
  }

  /// Select user role
  void selectRole(UserRole role) {
    emit(state.copyWith(selectedRole: role));
  }

  /// Add interest/topic
  void addInterest(String interest) {
    final updatedInterests = List<String>.from(state.interests)..add(interest);
    emit(state.copyWith(interests: updatedInterests));
  }

  /// Remove interest/topic
  void removeInterest(String interest) {
    final updatedInterests = List<String>.from(state.interests)
      ..remove(interest);
    emit(state.copyWith(interests: updatedInterests));
  }

  /// Set user name
  void setUserName(String name) {
    emit(state.copyWith(userName: name));
  }

  /// Give consent
  void giveConsent(bool given, String version) {
    emit(state.copyWith(
      consentGiven: given,
      consentVersion: version,
    ));
  }

  /// Complete onboarding - save to local storage
  Future<void> completeOnboarding() async {
    try {
      emit(state.copyWith(isLoading: true));

      final onboardingStatus = OnboardingStatus(
        isComplete: true,
        userRole: _mapRoleToString(state.selectedRole),
        consentGiven: state.consentGiven,
        consentVersion: state.consentVersion ?? '1.0',
        completedAt: DateTime.now(),
      );

      await _landingRepository.saveOnboardingStatus(onboardingStatus);

      emit(state.copyWith(
        currentStep: OnboardingStep.complete,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to complete onboarding',
      ));
    }
  }

  /// Reset onboarding (for testing/debugging)
  Future<void> resetOnboarding() async {
    await _landingRepository.clearOnboardingStatus();
    emit(const LandingState());
  }

  /// Clear error state
  void clearError() {
    emit(state.clearError());
  }

  // Helper methods
  OnboardingStep _getNextStep(OnboardingStep current) {
    switch (current) {
      case OnboardingStep.welcome:
        return OnboardingStep.roleSelection;
      case OnboardingStep.roleSelection:
        return OnboardingStep.contextGathering;
      case OnboardingStep.contextGathering:
        return OnboardingStep.consent;
      case OnboardingStep.consent:
        return OnboardingStep.complete;
      case OnboardingStep.complete:
        return OnboardingStep.complete;
    }
  }

  OnboardingStep? _getPreviousStep(OnboardingStep current) {
    switch (current) {
      case OnboardingStep.welcome:
        return null;
      case OnboardingStep.roleSelection:
        return OnboardingStep.welcome;
      case OnboardingStep.contextGathering:
        return OnboardingStep.roleSelection;
      case OnboardingStep.consent:
        return OnboardingStep.contextGathering;
      case OnboardingStep.complete:
        return null;
    }
  }

  String _mapRoleToString(UserRole? role) {
    switch (role) {
      case UserRole.expectingMother:
        return 'expecting_mother';
      case UserRole.healthcareProvider:
        return 'healthcare_provider';
      case UserRole.parentCaregiver:
        return 'parent_caregiver';
      case UserRole.explorer:
        return 'explorer';
      case null:
        return 'explorer';
    }
  }

  UserRole? _mapStringToRole(String? roleString) {
    switch (roleString) {
      case 'expecting_mother':
        return UserRole.expectingMother;
      case 'healthcare_provider':
        return UserRole.healthcareProvider;
      case 'parent_caregiver':
        return UserRole.parentCaregiver;
      case 'explorer':
        return UserRole.explorer;
      default:
        return null;
    }
  }
}