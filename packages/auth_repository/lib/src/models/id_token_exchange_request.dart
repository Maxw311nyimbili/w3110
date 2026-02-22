// packages/auth_repository/lib/src/models/id_token_exchange_request.dart

import 'package:equatable/equatable.dart';

/// Request body for exchanging Google ID token with backend
class IdTokenExchangeRequest extends Equatable {
  const IdTokenExchangeRequest({
    required this.idToken,
  });

  final String idToken; // Google ID token from Firebase Auth

  /// Convert to JSON for POST /auth/exchange
  /// Expected request body:
  /// {
  ///   "id_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6..."
  /// }
  Map<String, dynamic> toJson() {
    return {
      'id_token': idToken,
    };
  }

  @override
  List<Object?> get props => [idToken];
}
