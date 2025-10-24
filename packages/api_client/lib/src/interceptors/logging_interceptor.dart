// packages/api_client/lib/src/interceptors/logging_interceptor.dart

import 'package:dio/dio.dart';

/// Logging interceptor - logs all HTTP requests and responses
class LoggingInterceptor extends Interceptor {
  LoggingInterceptor({this.enabled = true});

  final bool enabled;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (enabled) {
      print('╔══════════════════════════════════════════════════════════');
      print('║ 📤 REQUEST');
      print('║ ${options.method} ${options.uri}');
      if (options.headers.isNotEmpty) {
        print('║ Headers:');
        options.headers.forEach((key, value) {
          // Don't log sensitive data
          if (key.toLowerCase() == 'authorization') {
            print('║   $key: Bearer ***');
          } else {
            print('║   $key: $value');
          }
        });
      }
      if (options.data != null) {
        print('║ Body: ${options.data}');
      }
      print('╚══════════════════════════════════════════════════════════');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (enabled) {
      print('╔══════════════════════════════════════════════════════════');
      print('║ 📥 RESPONSE');
      print('║ ${response.requestOptions.method} ${response.requestOptions.uri}');
      print('║ Status: ${response.statusCode}');
      print('║ Data: ${response.data}');
      print('╚══════════════════════════════════════════════════════════');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (enabled) {
      print('╔══════════════════════════════════════════════════════════');
      print('║ ❌ ERROR');
      print('║ ${err.requestOptions.method} ${err.requestOptions.uri}');
      print('║ Status: ${err.response?.statusCode}');
      print('║ Message: ${err.message}');
      if (err.response?.data != null) {
        print('║ Error Data: ${err.response?.data}');
      }
      print('╚══════════════════════════════════════════════════════════');
    }
    handler.next(err);
  }
}