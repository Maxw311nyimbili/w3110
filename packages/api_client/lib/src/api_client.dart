// packages/api_client/lib/src/api_client.dart

import 'package:dio/dio.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/error_interceptor.dart';

/// API client - handles all HTTP communication with backend
class ApiClient {
  ApiClient({
    required String baseUrl,
    required this.getAccessToken,
    required this.refreshToken,
    bool enableLogging = true,
    Duration? connectTimeout,
    Duration? receiveTimeout,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout ?? const Duration(seconds: 30),
        receiveTimeout: receiveTimeout ?? const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
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

  /// Function to get current access token
  final Future<String?> Function() getAccessToken;

  /// Function to refresh access token
  final Future<void> Function() refreshToken;

  /// GET request
  Future<Response<T>> get<T>(
      String path, {
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
        CancelToken? cancelToken,
      }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
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
      }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
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
      }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
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
      }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
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
      }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
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