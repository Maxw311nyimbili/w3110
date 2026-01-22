import 'package:equatable/equatable.dart';

enum OnboardingStep {
  welcome,
  authentication,
  roleSelection,
  profileSetup, // ← NEW: Capture name and account nickname
  contextGathering,
  consent,
  complete,
}

enum UserRole {
  mother,
  supportPartner,
  doctor,
  midwife,
  clinician,
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
    this.accountNickname,
    this.consentGiven = false,
    this.consentVersion,
    this.isLoading = false,
    this.error,
    this.authError,
    this.isAuthenticating = false,
    this.isVerified = false,
    this.verificationStatus = 'none',
    this.isDemoAvailable = false,
  });

  final OnboardingStep currentStep;
  final UserRole? selectedRole;
  final List<String> interests;
  final String? userName;
  final String? accountNickname;
  final bool consentGiven;
  final String? consentVersion;
  final bool isLoading;
  final String? error;
  final String? authError;
  final bool isAuthenticating;
  final bool isVerified;
  final String verificationStatus;
  final bool isDemoAvailable;

  bool get isComplete => currentStep == OnboardingStep.complete;
  bool get canProceed {
    switch (currentStep) {
      case OnboardingStep.welcome:
        return true;
      case OnboardingStep.authentication:
        return true; // Auth button always enabled
      case OnboardingStep.roleSelection:
        return selectedRole != null;
      case OnboardingStep.profileSetup:
        return userName != null && userName!.isNotEmpty && 
               accountNickname != null && accountNickname!.isNotEmpty;
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
    String? accountNickname,
    bool? consentGiven,
    String? consentVersion,
    bool? isLoading,
    String? error,
    String? authError,
    bool? isAuthenticating,
    bool? isVerified,
    String? verificationStatus,
    bool? isDemoAvailable,
  }) {
    return LandingState(
      currentStep: currentStep ?? this.currentStep,
      selectedRole: selectedRole ?? this.selectedRole,
      interests: interests ?? this.interests,
      userName: userName ?? this.userName,
      accountNickname: accountNickname ?? this.accountNickname,
      consentGiven: consentGiven ?? this.consentGiven,
      consentVersion: consentVersion ?? this.consentVersion,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      authError: authError,
      isAuthenticating: isAuthenticating ?? this.isAuthenticating,
      isVerified: isVerified ?? this.isVerified,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      isDemoAvailable: isDemoAvailable ?? this.isDemoAvailable,
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
    accountNickname,
    consentGiven,
    consentVersion,
    isLoading,
    error,
    authError,
    isAuthenticating,
    isVerified,
    verificationStatus,
    isDemoAvailable,
  ];
}
