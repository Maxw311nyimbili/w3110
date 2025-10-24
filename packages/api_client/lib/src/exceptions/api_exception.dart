// packages/api_client/lib/src/exceptions/api_exception.dart

import '../models/api_error.dart';

/// Exception thrown when API request fails
class ApiException implements Exception {
  ApiException({
    required this.error,
    this.stackTrace,
  });

  final ApiError error;
  final StackTrace? stackTrace;

  String get message => error.message;
  String? get code => error.code;
  int? get statusCode => error.statusCode;

  @override
  String toString() => 'ApiException: ${error.toString()}';
}

/// Exception thrown when network request times out
class NetworkTimeoutException extends ApiException {
  NetworkTimeoutException()
      : super(
    error: const ApiError(
      message: 'Request timed out - please check your connection',
      code: 'TIMEOUT',
    ),
  );
}

/// Exception thrown when device is offline
class NoInternetException extends ApiException {
  NoInternetException()
      : super(
    error: const ApiError(
      message: 'No internet connection - please check your network',
      code: 'NO_INTERNET',
    ),
  );
}

/// Exception thrown when authentication fails
class AuthenticationException extends ApiException {
  AuthenticationException({String? message})
      : super(
    error: ApiError(
      message: message ?? 'Authentication failed - please sign in again',
      code: 'AUTH_FAILED',
      statusCode: 401,
    ),
  );
}