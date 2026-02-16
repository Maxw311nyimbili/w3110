import 'package:auth_repository/auth_repository.dart';
import 'package:cap_project/features/auth/cubit/cubit.dart';
import 'package:cap_project/features/landing/cubit/landing_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:landing_repository/landing_repository.dart';

/// Manages onboarding flow including authentication step
///
/// Flow:
/// 1. Authentication - Google sign-in (now part of landing)
/// 2. Role Selection - user picks their primary role
/// 3. Profile Setup - name and account nickname
/// 4. Context Gathering - interests/topics (optional)
/// 5. Consent - medical disclaimer
/// 6. Complete - onboarding finished, ready for chat
class LandingCubit extends Cubit<LandingState> {
  LandingCubit({
    required LandingRepository landingRepository,
    required AuthRepository authRepository,
    required AuthCubit authCubit,
    bool isDevelopment = false,
  })  : _landingRepository = landingRepository,
        _authRepository = authRepository,
        _authCubit = authCubit,
        _isDevelopment = isDevelopment,
        super(LandingState(isDemoAvailable: isDevelopment));

  final LandingRepository _landingRepository;
  final AuthRepository _authRepository;
  final AuthCubit _authCubit;
  final bool _isDevelopment;

  /// Initialize - check if onboarding already completed
  Future<void> initialize({OnboardingStep? initialStepOverride}) async {
    try {
      print('🚀 Initializing LandingCubit...');
      emit(state.copyWith(isLoading: true));

      if (initialStepOverride != null) {
        print('➡️ Jumping directly to step: $initialStepOverride');
        emit(state.copyWith(
          currentStep: initialStepOverride,
          isLoading: false,
          isGuest: false,
        ));
        return;
      }

      final status = await _landingRepository.getOnboardingStatus();
      print('  - Onboarding complete: ${status.isComplete}');
      
      final isAuthenticated = await _authRepository.isAuthenticated();
      print('  - User authenticated: $isAuthenticated');

      // Prefer backend's source of truth for onboarding status if authenticated
      final bool isBackendOnboarded = _authCubit.state.user?.onboardingCompleted ?? false;
      final bool isOnboarded = (status.isComplete || isBackendOnboarded) && isAuthenticated;

      if (isOnboarded) {
        print('✅ Onboarding already done, moving to complete');
        emit(state.copyWith(
          currentStep: OnboardingStep.complete,
          isGuest: false,
          selectedRole: _mapStringToRole(status.userRole),
          userName: status.userName,
          accountNickname: status.accountNickname,
          interests: status.interests,
          consentGiven: status.consentGiven,
          consentVersion: status.consentVersion,
          isLoading: false,
        ));
      } else if (isAuthenticated) {
        print('ℹ️ User authenticated but onboarding incomplete. Jumping to role selection.');
        emit(state.copyWith(
          currentStep: OnboardingStep.roleSelection,
          isGuest: false,
          selectedRole: _mapStringToRole(status.userRole),
          userName: status.userName,
          accountNickname: status.accountNickname,
          interests: status.interests,
          consentGiven: status.consentGiven,
          consentVersion: status.consentVersion,
          isLoading: false,
        ));
      } else {
        print('ℹ️ Starting onboarding flow');
        emit(state.copyWith(
          isLoading: false,
          isGuest: !isAuthenticated,
        ));
      }
    } catch (e, stackTrace) {
      print('❌ ERROR in LandingCubit.initialize: $e');
      print(stackTrace);
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load onboarding status: ${e.toString()}',
      ));
    }
  }

  /// Move to next onboarding step
  Future<void> nextStep() async {
    if (!state.canProceed) return;

    final nextStep = _getNextStep(state.currentStep);
    emit(state.copyWith(currentStep: nextStep, isGuest: false));
  }

  /// Continue as a guest (bypass onboarding for now)
  void continueAsGuest() {
    print('👤 Guest access: bypassing auth and jumping to complete');
    emit(state.copyWith(
      currentStep: OnboardingStep.complete,
      isGuest: true,
    ));
  }

  /// Manually start authentication (from CTA or restricted feature)
  void startAuthentication() {
    emit(state.copyWith(
      currentStep: OnboardingStep.authentication,
      isGuest: false,
    ));
  }

  /// Move to previous onboarding step
  void previousStep() {
    final previousStep = _getPreviousStep(state.currentStep);
    if (previousStep != null) {
      emit(state.copyWith(currentStep: previousStep));
    }
  }

  /// Authenticate with Google as part of onboarding
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

      // Update state with Google user info
      final authUser = AuthUser(
        id: user.id,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoUrl,
        role: user.role,
      );

      emit(state.copyWith(
        isAuthenticating: false,
        authError: null,
        userName: user.displayName,
      ));

      // Sync global AuthCubit state immediately
      _authCubit.onUserAuthenticated(authUser);

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

  /// Authenticate as demo user (Bypass)
  Future<void> authenticateAsDemo() async {
    try {
      emit(state.copyWith(isAuthenticating: true, authError: null));

      // Sign in as demo user via AuthCubit
      await _authCubit.signInAsDemo();
      
      final user = _authCubit.state.user;
      if (user == null) throw Exception('Demo login failed');

      print('✓ Demo Authentication complete: ${user.email}');
      
      // Update state with Demo user info
      emit(state.copyWith(
        isAuthenticating: false,
        authError: null,
        userName: user.displayName,
      ));

      // Sync global AuthCubit state immediately
      _authCubit.onUserAuthenticated(user);

      // Move to next step (role selection)
      nextStep();
    } catch (e) {
      print('❌ Demo Sign-in error: $e');
      emit(state.copyWith(
        isAuthenticating: false,
        authError: 'Demo Sign-in failed: ${e.toString()}',
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
    // Professional roles start as unverified
    final isProfessional = role == UserRole.doctor || 
                          role == UserRole.midwife || 
                          role == UserRole.clinician;
    
    emit(state.copyWith(
      selectedRole: role,
      isVerified: !isProfessional,
      verificationStatus: isProfessional ? 'pending' : 'none',
      // Suggest account nickname based on role
      accountNickname: _suggestNickname(role, state.userName),
    ));
  }

  String _suggestNickname(UserRole role, String? name) {
    final roleName = _mapRoleToString(role).replaceAll('_', ' ');
    final capitalized = roleName[0].toUpperCase() + roleName.substring(1);
    if (name != null && name.isNotEmpty) {
      return '$capitalized Profile - $name';
    }
    return '$capitalized Profile';
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

  /// Set account nickname
  void setAccountNickname(String name) {
    emit(state.copyWith(accountNickname: name));
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
        userName: state.userName,
        accountNickname: state.accountNickname,
        interests: state.interests,
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

  /// Reset all local app data (for testing/debugging or deep logout)
  Future<void> resetOnboarding() async {
    await _landingRepository.clearAllLocalData();
    emit(LandingState(isDemoAvailable: _isDevelopment));
  }

  /// Clear error state
  void clearError() {
    emit(state.clearError());
  }

  // ============ Helper methods ============

  OnboardingStep _getNextStep(OnboardingStep current) {
    switch (current) {
      case OnboardingStep.authentication:
        return OnboardingStep.roleSelection;
      case OnboardingStep.roleSelection:
        return OnboardingStep.profileSetup;
      case OnboardingStep.profileSetup:
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
      case OnboardingStep.authentication:
        return null;
      case OnboardingStep.roleSelection:
        return OnboardingStep.authentication;
      case OnboardingStep.profileSetup:
        return OnboardingStep.roleSelection;
      case OnboardingStep.contextGathering:
        return OnboardingStep.profileSetup;
      case OnboardingStep.consent:
        return OnboardingStep.contextGathering;
      case OnboardingStep.complete:
        return null;
    }
  }

  String _mapRoleToString(UserRole? role) {
    switch (role) {
      case UserRole.mother:
        return 'mother';
      case UserRole.supportPartner:
        return 'support_partner';
      case UserRole.doctor:
        return 'doctor';
      case UserRole.midwife:
        return 'midwife';
      case UserRole.clinician:
        return 'clinician';
      case null:
        return 'mother';
    }
  }

  UserRole? _mapStringToRole(String? roleString) {
    switch (roleString) {
      case 'mother':
        return UserRole.mother;
      case 'support_partner':
        return UserRole.supportPartner;
      case 'doctor':
        return UserRole.doctor;
      case 'midwife':
        return UserRole.midwife;
      case 'clinician':
        return UserRole.clinician;
      default:
        return null;
    }
  }
}