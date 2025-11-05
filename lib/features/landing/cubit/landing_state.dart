import 'package:equatable/equatable.dart';

enum OnboardingStep {
  welcome,
  authentication, // ← NEW: Auth step happens before customization
  roleSelection,
  contextGathering,
  consent,
  complete,
}

enum UserRole {
  expectingMother,
  healthcareProvider,
  parentCaregiver,
  explorer,
}

/// Immutable state for landing/onboarding flow
///
/// Flow: Welcome → Auth → Role Selection → Context Gathering → Consent → Complete
class LandingState extends Equatable {
  const LandingState({
    this.currentStep = OnboardingStep.welcome,
    this.selectedRole,
    this.interests = const [],
    this.userName,
    this.consentGiven = false,
    this.consentVersion,
    this.isLoading = false,
    this.error,
    this.authError, // ← NEW: Track auth errors separately
    this.isAuthenticating = false, // ← NEW: Track auth loading state
  });

  final OnboardingStep currentStep;
  final UserRole? selectedRole;
  final List<String> interests;
  final String? userName;
  final bool consentGiven;
  final String? consentVersion;
  final bool isLoading;
  final String? error;
  final String? authError; // ← NEW
  final bool isAuthenticating; // ← NEW

  bool get isComplete => currentStep == OnboardingStep.complete;
  bool get canProceed {
    switch (currentStep) {
      case OnboardingStep.welcome:
        return true;
      case OnboardingStep.authentication:
        return true; // Auth button always enabled
      case OnboardingStep.roleSelection:
        return selectedRole != null;
      case OnboardingStep.contextGathering:
        return true; // Optional step
      case OnboardingStep.consent:
        return consentGiven;
      case OnboardingStep.complete:
        return true;
    }
  }

  LandingState copyWith({
    OnboardingStep? currentStep,
    UserRole? selectedRole,
    List<String>? interests,
    String? userName,
    bool? consentGiven,
    String? consentVersion,
    bool? isLoading,
    String? error,
    String? authError,
    bool? isAuthenticating,
  }) {
    return LandingState(
      currentStep: currentStep ?? this.currentStep,
      selectedRole: selectedRole ?? this.selectedRole,
      interests: interests ?? this.interests,
      userName: userName ?? this.userName,
      consentGiven: consentGiven ?? this.consentGiven,
      consentVersion: consentVersion ?? this.consentVersion,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      authError: authError,
      isAuthenticating: isAuthenticating ?? this.isAuthenticating,
    );
  }

  LandingState clearError() {
    return copyWith(error: null, authError: null);
  }

  @override
  List<Object?> get props => [
    currentStep,
    selectedRole,
    interests,
    userName,
    consentGiven,
    consentVersion,
    isLoading,
    error,
    authError,
    isAuthenticating,
  ];
}