// lib/features/auth/cubit/auth_cubit.dart - COMPLETE IMPLEMENTATION

import 'package:auth_repository/auth_repository.dart';
import 'package:cap_project/features/auth/cubit/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Manages authentication state and user sessions
///
/// Authentication flow:
/// 1. signInWithGoogle() → triggers Google Sign-In in Firebase
/// 2. Firebase returns ID token
/// 3. exchangeTokenWithBackend() → exchanges ID token with backend
/// 4. Backend returns JWT access/refresh tokens
/// 5. Tokens stored securely
/// 6. User info retrieved and emitted
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const AuthState());

  final AuthRepository _authRepository;

  /// Initialize auth - check for existing session
  /// Called when app starts to see if user is already logged in
  Future<void> initialize() async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));

      print('🔐 Initializing authentication...');

      // Check if user has valid tokens
      final isAuthenticated = await _authRepository.isAuthenticated();

      if (isAuthenticated) {
        // Force a backend check to ensure the user still exists
        // (Handles the case where user was deleted from DB but tokens still exist locally)
        final user = await _authRepository.getCurrentUser(forceRefresh: true);

        if (user != null) {
          print('✓ User session restored: ${user.email}');
          emit(state.copyWith(
            status: AuthStatus.authenticated,
            user: _mapToAuthUser(user),
          ));
          return;
        } else {
          print('⚠️ Session tokens valid but user not found on backend. Clearing stale session.');
          await _authRepository.signOut();
        }
      }

      // No valid session
      print('ℹ️ No existing session found');
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    } catch (e) {
      print('❌ Auth initialization error: $e');
      emit(state.copyWith(
        status: AuthStatus.error,
        error: 'Failed to initialize authentication',
      ));
    }
  }

  /// Sign in with Google OAuth via Firebase
  ///
  /// Complete flow:
  /// 1. User taps "Sign in with Google" button
  /// 2. Google Sign-In UI appears
  /// 3. User selects their Google account
  /// 4. Firebase handles authentication
  /// 5. Get Firebase ID token
  /// 6. Exchange ID token with backend for JWT tokens
  /// 7. Store tokens securely
  /// 8. Fetch and store user info
  /// 9. Update state to authenticated
  Future<void> signInWithGoogle() async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));

      print('🔐 Starting Google Sign-In...');

      // Step 1: Get Firebase ID token from Google Sign-In
      final firebaseIdToken = await _authRepository.signInWithGoogle();

      if (firebaseIdToken == null) {
        print('ℹ️ Google Sign-In was cancelled');
        emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          error: 'Sign-in was cancelled',
        ));
        return;
      }

      print('✓ Got Firebase ID token');

      // Step 2: Exchange Firebase ID token with backend
      // This call sends the ID token to POST /auth/exchange
      // Backend verifies it with Firebase Admin SDK and returns JWT tokens
      final authTokens = await _authRepository.exchangeIdToken(
        IdTokenExchangeRequest(idToken: firebaseIdToken),
      );

      print('✓ Exchanged ID token for JWT tokens');
      print('  - Access token expires in: ${authTokens.expiresIn}s');

      // Step 3: Get current user from backend
      // The API client now has the access token and will use it for all requests
      final user = await _authRepository.getCurrentUser();

      if (user == null) {
        throw Exception('Failed to get user after authentication');
      }

      print('✓ Authentication complete: ${user.email}');

      // Step 4: Update state to authenticated
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: _mapToAuthUser(user),
      ));
    } on AuthException catch (e) {
      print('❌ Auth error: $e');
      emit(state.copyWith(
        status: AuthStatus.error,
        error: e.message,
      ));
    } catch (e) {
      print('❌ Sign-in error: $e');
      emit(state.copyWith(
        status: AuthStatus.error,
        error: 'Sign-in failed: ${e.toString()}',
      ));
    }
  }

  /// Sign in as a demo user (Development only)
  Future<void> signInAsDemo() async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));
      final user = await _authRepository.signInAsDemo();
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: _mapToAuthUser(user),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        error: 'Demo sign-in failed',
      ));
    }
  }

  /// Sign out - clear tokens and user data
  ///
  /// Steps:
  /// 1. Sign out from Firebase
  /// 2. Sign out from Google
  /// 3. Clear stored tokens
  /// 4. Update state to unauthenticated
  Future<void> signOut() async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));

      print('🔐 Signing out...');

      // Sign out from Firebase and Google
      await _authRepository.signOut();

      print('✓ Signed out successfully');

      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
      ));
    } on AuthException catch (e) {
      print('❌ Sign-out error: $e');
      emit(state.copyWith(
        status: AuthStatus.error,
        error: e.message,
      ));
    } catch (e) {
      print('❌ Sign-out error: $e');
      emit(state.copyWith(
        status: AuthStatus.error,
        error: 'Sign-out failed: ${e.toString()}',
      ));
    }
  }

  /// Refresh authentication tokens when they expire
  ///
  /// This is typically called automatically by the API client interceptor
  /// when an access token expires. This method can be called manually
  /// if needed.
  ///
  /// The backend endpoint POST /auth/refresh:
  /// - Accepts the refresh token
  /// - Validates it
  /// - Returns a new access token
  Future<void> refreshToken() async {
    try {
      print('🔄 Refreshing access token...');

      // Call the repository to refresh
      await _authRepository.refreshToken();

      print('✓ Access token refreshed');

      // Optionally update user info
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(state.copyWith(
          user: _mapToAuthUser(user),
        ));
      }
    } on AuthException catch (e) {
      print('❌ Token refresh failed: $e');
      // Refresh failed - sign out user
      await signOut();
      emit(state.copyWith(
        status: AuthStatus.error,
        error: 'Session expired. Please sign in again.',
      ));
    } catch (e) {
      print(' Refresh error: $e');
      await signOut();
    }
  }

  /// Called externally when user authenticates via another flow (e.g. Landing/Onboarding)
  /// to sync the global authentication state immediately.
  void onUserAuthenticated(AuthUser user) {
    emit(state.copyWith(
      status: AuthStatus.authenticated,
      user: user,
    ));
  }

  /// Clear error state
  void clearError() {
    emit(state.clearError());
  }

  /// Helper to map repository user model to auth state user model
  AuthUser? _mapToAuthUser(User? user) {
    if (user == null) return null;

    return AuthUser(
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
      role: user.role,
      onboardingCompleted: user.onboardingCompleted,
    );
  }
}