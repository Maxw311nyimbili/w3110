// packages/api_client/lib/src/interceptors/error_interceptor.dart

import 'package:dio/dio.dart';
import '../models/api_error.dart';
import '../exceptions/api_exception.dart';

/// Error interceptor - converts Dio errors to ApiExceptions
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    ApiException exception;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        exception = NetworkTimeoutException();
        break;

      case DioExceptionType.connectionError:
        exception = NoInternetException();
        break;

      case DioExceptionType.badResponse:
        // Parse error from response
        final statusCode = err.response?.statusCode;
        final data = err.response?.data;

        if (statusCode == 401) {
          exception = AuthenticationException();
        } else if (data != null && data is Map<String, dynamic>) {
          // Try to parse structured error from backend
          try {
            final apiError = ApiError.fromJson(data);
            exception = ApiException(
              error: apiError.copyWith(statusCode: statusCode),
            );
          } catch (_) {
            // Fallback to generic error
            exception = ApiException(
              error: ApiError.fromStatusCode(
                statusCode ?? 500,
                message: data['message'] as String?,
              ),
            );
          }
        } else {
          exception = ApiException(
            error: ApiError.fromStatusCode(statusCode ?? 500),
          );
        }
        break;

      case DioExceptionType.cancel:
        exception = ApiException(
          error: const ApiError(
            message: 'Request was cancelled',
            code: 'CANCELLED',
          ),
        );
        break;

      default:
        exception = ApiException(
          error: ApiError(
            message: err.message ?? 'An unexpected error occurred',
            code: 'UNKNOWN',
          ),
        );
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,
        type: err.type,
      ),
    );
  }
}

/// Extension to add copyWith to ApiError
extension ApiErrorCopyWith on ApiError {
  ApiError copyWith({
    String? message,
    String? code,
    int? statusCode,
    Map<String, dynamic>? details,
  }) {
    return ApiError(
      message: message ?? this.message,
      code: code ?? this.code,
      statusCode: statusCode ?? this.statusCode,
      details: details ?? this.details,
    );
  }
}
