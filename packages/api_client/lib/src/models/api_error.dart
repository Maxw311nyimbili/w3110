// packages/api_client/lib/src/models/api_error.dart

import 'package:equatable/equatable.dart';

/// API error response model
class ApiError extends Equatable {
  const ApiError({
    required this.message,
    this.code,
    this.statusCode,
    this.details,
  });

  final String message;
  final String? code; // Error code from backend (e.g., 'AUTH_FAILED')
  final int? statusCode; // HTTP status code (e.g., 401, 500)
  final Map<String, dynamic>? details; // Additional error details

  /// Parse from backend error response
  /// Expected format:
  /// {
  ///   "error": {
  ///     "message": "Invalid credentials",
  ///     "code": "AUTH_FAILED",
  ///     "details": { ... }
  ///   }
  /// }
  factory ApiError.fromJson(Map<String, dynamic> json) {
    final error = json['error'] as Map<String, dynamic>?;

    return ApiError(
      message: error?['message'] as String? ?? 'An error occurred',
      code: error?['code'] as String?,
      details: error?['details'] as Map<String, dynamic>?,
    );
  }

  /// Create from HTTP status code
  factory ApiError.fromStatusCode(int statusCode, {String? message}) {
    return ApiError(
      message: message ?? _getDefaultMessage(statusCode),
      statusCode: statusCode,
    );
  }

  static String _getDefaultMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request';
      case 401:
        return 'Unauthorized - please sign in';
      case 403:
        return 'Forbidden - insufficient permissions';
      case 404:
        return 'Resource not found';
      case 429:
        return 'Too many requests - please try again later';
      case 500:
        return 'Server error - please try again';
      case 503:
        return 'Service unavailable - please try again later';
      default:
        return 'Request failed with status $statusCode';
    }
  }

  @override
  List<Object?> get props => [message, code, statusCode, details];

  @override
  String toString() => 'ApiError: $message (code: $code, status: $statusCode)';
}
