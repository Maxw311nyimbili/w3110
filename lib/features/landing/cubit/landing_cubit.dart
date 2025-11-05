import 'package:auth_repository/auth_repository.dart';
import 'package:cap_project/features/landing/cubit/landing_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:landing_repository/landing_repository.dart';

/// Manages onboarding flow including authentication step
///
/// Flow:
/// 1. Welcome - intro screen
/// 2. Authentication - Google sign-in (now part of landing)
/// 3. Role Selection - user picks their primary role
/// 4. Context Gathering - interests/topics (optional)
/// 5. Consent - medical disclaimer
/// 6. Complete - onboarding finished, ready for chat
class LandingCubit extends Cubit<LandingState> {
  LandingCubit({
    required LandingRepository landingRepository,
    required AuthRepository authRepository,
  })  : _landingRepository = landingRepository,
        _authRepository = authRepository,
        super(const LandingState());

  final LandingRepository _landingRepository;
  final AuthRepository _authRepository;

  /// Initialize - check if onboarding already completed
  Future<void> initialize() async {
    try {
      emit(state.copyWith(isLoading: true));

      final status = await _landingRepository.getOnboardingStatus();

      if (status.isComplete) {
        // Onboarding already done, go straight to complete
        emit(state.copyWith(
          currentStep: OnboardingStep.complete,
          selectedRole: _mapStringToRole(status.userRole),
          consentGiven: status.consentGiven,
          consentVersion: status.consentVersion,
          isLoading: false,
        ));
      } else {
        // Start onboarding from welcome
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

  /// Authenticate with Google as part of onboarding
  /// This is called from the authentication step
  Future<void> authenticateWithGoogle() async {
    try {
      emit(state.copyWith(isAuthenticating: true, authError: null));

      print('🔐 Starting Google Sign-In from onboarding...');

      // Get Firebase ID token from Google Sign-In
      final firebaseIdToken = await _authRepository.signInWithGoogle();

      if (firebaseIdToken == null) {
        print('ℹ️ Google Sign-In was cancelled');
        emit(state.copyWith(
          isAuthenticating: false,
          authError: 'Sign-in was cancelled',
        ));
        return;
      }

      print('✓ Got Firebase ID token');

      // Exchange Firebase ID token with backend
      final authTokens = await _authRepository.exchangeIdToken(
        IdTokenExchangeRequest(idToken: firebaseIdToken),
      );

      print('✓ Exchanged ID token for JWT tokens');
      print('  - Access token expires in: ${authTokens.expiresIn}s');

      // Get current user from backend
      final user = await _authRepository.getCurrentUser();

      if (user == null) {
        throw Exception('Failed to get user after authentication');
      }

      print('✓ Authentication complete: ${user.email}');

      // Authentication successful - move to role selection
      emit(state.copyWith(
        isAuthenticating: false,
        authError: null,
      ));

      // Move to next step (role selection)
      nextStep();
    } on AuthException catch (e) {
      print('❌ Auth error: $e');
      emit(state.copyWith(
        isAuthenticating: false,
        authError: e.message,
      ));
    } catch (e) {
      print('❌ Sign-in error: $e');
      emit(state.copyWith(
        isAuthenticating: false,
        authError: 'Sign-in failed: ${e.toString()}',
      ));
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

  // ============ Helper methods ============

  OnboardingStep _getNextStep(OnboardingStep current) {
    switch (current) {
      case OnboardingStep.welcome:
        return OnboardingStep.authentication; // ← Auth is next after welcome
      case OnboardingStep.authentication:
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
      case OnboardingStep.authentication:
        return OnboardingStep.welcome; // ← Can go back to welcome
      case OnboardingStep.roleSelection:
        return OnboardingStep.authentication; // ← Can go back to auth
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