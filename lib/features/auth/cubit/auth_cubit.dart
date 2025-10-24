// lib/features/auth/cubit/auth_cubit.dart

import 'package:auth_repository/auth_repository.dart';
import 'package:cap_project/features/auth/cubit/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Manages authentication state and user sessions
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const AuthState());

  final AuthRepository _authRepository;

  /// Initialize auth - check for existing session
  Future<void> initialize() async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));

      final user = await _authRepository.getCurrentUser();

      if (user != null) {
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: _mapToAuthUser(user),
        ));
      } else {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        error: 'Failed to initialize authentication',
      ));
    }
  }

  /// Sign in with Google OAuth
  /// Flow: Google Sign-In → Get ID Token → Exchange with Backend → Get Access/Refresh Tokens
  Future<void> signInWithGoogle() async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));

      // TODO: Uncomment when Firebase Auth is configured
      /*
      // Step 1: Trigger Google Sign-In via Firebase Auth
      final googleIdToken = await _authRepository.signInWithGoogle();

      if (googleIdToken == null) {
        emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          error: 'Google sign-in was cancelled',
        ));
        return;
      }

      // Step 2: Exchange Google ID token with backend
      // Backend endpoint: POST /auth/exchange
      // Request body: { "id_token": "google_id_token_here" }
      // Response: { "access_token": "...", "refresh_token": "...", "user": {...} }
      final authTokens = await _authRepository.exchangeIdToken(
        IdTokenExchangeRequest(idToken: googleIdToken),
      );

      // Step 3: Store tokens securely (handled by repository)
      // Repository will save access_token and refresh_token to secure storage

      // Step 4: Get current user from backend using access token
      final user = await _authRepository.getCurrentUser();

      if (user == null) {
        throw Exception('Failed to get user after authentication');
      }

      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: _mapToAuthUser(user),
      ));
      */

      // TEMPORARY: Mock successful auth for development
      await Future.delayed(const Duration(seconds: 1));

      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: const AuthUser(
          id: 'mock_user_123',
          email: 'demo@medlink.dev',
          displayName: 'Demo User',
          photoUrl: null,
          role: 'expecting_mother',
        ),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        error: 'Sign-in failed: ${e.toString()}',
      ));
    }
  }

  /// Sign out - clear tokens and user data
  Future<void> signOut() async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));

      // TODO: Uncomment when Firebase Auth is configured
      /*
      // Sign out from Firebase
      await _authRepository.signOut();
      // Repository will also clear stored tokens from secure storage
      */

      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        error: 'Sign-out failed: ${e.toString()}',
      ));
    }
  }

  /// Refresh authentication tokens when they expire
  /// TODO: Implement when backend token refresh endpoint is ready
  /// Backend endpoint: POST /auth/refresh
  /// Request body: { "refresh_token": "stored_refresh_token" }
  /// Response: { "access_token": "new_access_token" }
  Future<void> refreshToken() async {
    try {
      // await _authRepository.refreshToken();
      // If successful, tokens are updated silently in secure storage
      // If refresh fails (expired refresh token), force sign out
    } catch (e) {
      // Refresh token expired or invalid - sign out user
      await signOut();
    }
  }

  /// Clear error state
  void clearError() {
    emit(state.clearError());
  }

  /// DEVELOPMENT ONLY: Bypass auth for testing UI without backend
  /// TODO: Remove this method before production deployment
  void bypassAuth() {
    emit(state.copyWith(
      status: AuthStatus.authenticated,
      user: const AuthUser(
        id: 'bypass_user_dev',
        email: 'bypass@dev.local',
        displayName: 'Dev Bypass User',
        role: 'expecting_mother',
      ),
    ));
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
    );
  }
}