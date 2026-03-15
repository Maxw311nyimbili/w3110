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
    print('🔑 AuthInterceptor: ${options.method} ${options.path}');
    print('   Full URL: ${options.uri}');
    print(
      '   Timeouts - Connect: ${options.connectTimeout}, Receive: ${options.receiveTimeout}',
    );

    // Skip auth for public endpoints
    if (_isPublicEndpoint(options.path)) {
      print('🔓 Public endpoint - skipping auth');
      return handler.next(options);
    }

    print('🔑 Getting access token...');

    // Get access token
    final token = await getAccessToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
      print(
        '✅ Authorization header added: Bearer ${token.substring(0, 15)}...',
      );
    } else {
      print('⚠️  No token available - request may fail');
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    print(
      '❌ Request error: ${err.response?.statusCode} ${err.requestOptions.path}',
    );
    print('   Error type: ${err.type}');
    print('   Error message: ${err.message}');
    print('   Request: ${err.requestOptions.method} ${err.requestOptions.uri}');

    // Handle 401 Unauthorized - try to refresh token
    if (err.response?.statusCode == 401) {
      print('🔄 401 Unauthorized - attempting token refresh...');

      try {
        // Refresh token
        await refreshToken();

        // Get new access token
        final newToken = await getAccessToken();

        if (newToken != null && newToken.isNotEmpty) {
          print('✅ Token refreshed - retrying request...');

          // Retry request with new token
          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer $newToken';

          final response = await Dio().fetch(options);
          return handler.resolve(response);
        } else {
          print('❌ Token refresh failed - no new token');
        }
      } catch (e) {
        print('❌ Token refresh error: $e');
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
      '/health',
      '/announcements',
      '/consent/',
    ];

    return publicPaths.any((p) => path.contains(p));
  }
}
