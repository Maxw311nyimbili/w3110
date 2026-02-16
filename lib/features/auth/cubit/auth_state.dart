// lib/features/auth/cubit/auth_state.dart

import 'package:equatable/equatable.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
  error,
}

/// Immutable auth state - tracks user authentication status
class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
    this.idToken,
  });

  final AuthStatus status;
  final AuthUser? user;
  final String? error;
  final String? idToken; // Google ID token before backend exchange

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get isLoading => status == AuthStatus.loading;

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    String? error,
    String? idToken,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
      idToken: idToken ?? this.idToken,
    );
  }

  AuthState clearError() {
    return copyWith(error: null);
  }

  @override
  List<Object?> get props => [status, user, error, idToken];
}

/// Minimal user model for auth state
class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.role,
    this.onboardingCompleted = false,
  });

  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? role;
  final bool onboardingCompleted;

  @override
  List<Object?> get props => [id, email, displayName, photoUrl, role, onboardingCompleted];
}