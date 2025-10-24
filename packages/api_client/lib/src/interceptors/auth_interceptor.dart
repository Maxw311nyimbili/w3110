// packages/api_client/lib/src/interceptors/auth_interceptor.dart

import 'package:dio/dio.dart';

/// Auth interceptor - adds access token to requests
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.getAccessToken,
    required this.refreshToken,
  });

  /// Function to get current access token
  final Future<String?> Function() getAccessToken;

  /// Function to refresh access token when expired
  final Future<void> Function() refreshToken;

  @override
  Future<void> onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    // Skip auth for public endpoints
    if (_isPublicEndpoint(options.path)) {
      return handler.next(options);
    }

    // Get access token
    final token = await getAccessToken();

    if (token != null) {
      // Add Authorization header
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
      DioException err,
      ErrorInterceptorHandler handler,
      ) async {
    // Handle 401 Unauthorized - try to refresh token
    if (err.response?.statusCode == 401) {
      try {
        // Refresh token
        await refreshToken();

        // Get new access token
        final newToken = await getAccessToken();

        if (newToken != null) {
          // Retry request with new token
          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer $newToken';

          final response = await Dio().fetch(options);
          return handler.resolve(response);
        }
      } catch (e) {
        // Refresh failed - pass error through
        return handler.next(err);
      }
    }

    handler.next(err);
  }

  /// Check if endpoint is public (doesn't require auth)
  bool _isPublicEndpoint(String path) {
    const publicPaths = [
      '/auth/exchange',
      '/auth/refresh',
      '/consent/current',
      '/announcements',
    ];

    return publicPaths.any((p) => path.contains(p));
  }
}