// packages/auth_repository/lib/src/models/auth_tokens.dart

import 'package:equatable/equatable.dart';

/// Auth tokens returned from backend after token exchange
class AuthTokens extends Equatable {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    this.expiresIn,
  });

  final String accessToken;
  final String refreshToken;
  final int? expiresIn; // Seconds until access token expires

  /// Create from backend JSON response
  /// Expected response from POST /auth/exchange:
  /// {
  ///   "access_token": "...",
  ///   "refresh_token": "...",
  ///   "expires_in": 3600
  /// }
  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresIn: json['expires_in'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_in': expiresIn,
    };
  }

  @override
  List<Object?> get props => [accessToken, refreshToken, expiresIn];
}