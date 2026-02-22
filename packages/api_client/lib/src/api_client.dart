// packages/api_client/lib/src/api_client.dart

import 'package:api_client/src/interceptors/auth_interceptor.dart';
import 'package:api_client/src/interceptors/error_interceptor.dart';
import 'package:api_client/src/interceptors/logging_interceptor.dart';
import 'package:dio/dio.dart';

/// API client - handles all HTTP communication with backend
class ApiClient {
  ApiClient({
    required String baseUrl,
    required this.getAccessToken,
    required this.refreshToken,
    bool enableLogging = true,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    String? locale,
  }) : _currentLocale = locale ?? 'en' {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout ?? const Duration(seconds: 15),
        receiveTimeout:
            receiveTimeout ?? const Duration(seconds: 300), // 5 minutes max
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Accept-Language': _currentLocale,
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.addAll([
      AuthInterceptor(
        getAccessToken: getAccessToken,
        refreshToken: refreshToken,
      ),
      ErrorInterceptor(),
      if (enableLogging) LoggingInterceptor(enabled: true),
    ]);
  }

  late final Dio _dio;
  String _currentLocale;

  /// Function to get current access token
  final Future<String?> Function() getAccessToken;

  /// Function to refresh access token
  final Future<void> Function() refreshToken;

  /// Set the current locale for API requests
  void setLocale(String locale) {
    _currentLocale = locale;
    _dio.options.headers['Accept-Language'] = locale;
  }

  /// Get the current locale
  String get currentLocale => _currentLocale;

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
    Duration? receiveTimeout,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
          receiveTimeout: receiveTimeout,
        ),
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw e.error ?? e;
    }
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
    Duration? receiveTimeout,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
          receiveTimeout: receiveTimeout,
        ),
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw e.error ?? e;
    }
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
    Duration? receiveTimeout,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
          receiveTimeout: receiveTimeout,
        ),
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw e.error ?? e;
    }
  }

  /// PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
    Duration? receiveTimeout,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
          receiveTimeout: receiveTimeout,
        ),
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw e.error ?? e;
    }
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
    Duration? receiveTimeout,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
          receiveTimeout: receiveTimeout,
        ),
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw e.error ?? e;
    }
  }

  /// Upload file (multipart)
  Future<Response<T>> uploadFile<T>(
    String path, {
    required String filePath,
    required String fieldName,
    Map<String, dynamic>? additionalData,
    Map<String, dynamic>? headers,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        if (additionalData != null) ...additionalData,
      });

      return await _dio.post<T>(
        path,
        data: formData,
        options: Options(headers: headers),
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw e.error ?? e;
    }
  }

  /// Download file
  Future<Response> downloadFile(
    String path,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.download(
        path,
        savePath,
        queryParameters: queryParameters,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw e.error ?? e;
    }
  }

  /// Get underlying Dio instance (for advanced use cases)
  Dio get dio => _dio;
}
