// packages/api_client/lib/src/interceptors/logging_interceptor.dart

import 'dart:developer' as developer;
import 'package:dio/dio.dart';

/// Logging interceptor - logs all HTTP requests and responses
class LoggingInterceptor extends Interceptor {
  LoggingInterceptor({this.enabled = true});

  final bool enabled;

  void _log(String message) {
    print(message);
    developer.log(message, name: 'api_client');
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (enabled) {
      final buffer = StringBuffer();
      buffer.writeln(
        '╔══════════════════════════════════════════════════════════',
      );
      buffer.writeln('║ 📤 REQUEST');
      buffer.writeln('║ ${options.method} ${options.uri}');
      if (options.headers.isNotEmpty) {
        buffer.writeln('║ Headers:');
        options.headers.forEach((key, value) {
          // Don't log sensitive data
          if (key.toLowerCase() == 'authorization') {
            buffer.writeln('║   $key: Bearer ***');
          } else {
            buffer.writeln('║   $key: $value');
          }
        });
      }
      if (options.data != null) {
        buffer.writeln('║ Body: ${options.data}');
      }
      buffer.writeln(
        '╚══════════════════════════════════════════════════════════',
      );
      _log(buffer.toString());
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (enabled) {
      final buffer = StringBuffer();
      buffer.writeln(
        '╔══════════════════════════════════════════════════════════',
      );
      buffer.writeln('║ 📥 RESPONSE');
      buffer.writeln(
        '║ ${response.requestOptions.method} ${response.requestOptions.uri}',
      );
      buffer.writeln('║ Status: ${response.statusCode}');
      buffer.writeln('║ Data: ${response.data}');
      buffer.writeln(
        '╚══════════════════════════════════════════════════════════',
      );
      _log(buffer.toString());
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (enabled) {
      final buffer = StringBuffer();
      buffer.writeln(
        '╔══════════════════════════════════════════════════════════',
      );
      buffer.writeln('║ ❌ ERROR');
      buffer.writeln(
        '║ ${err.requestOptions.method} ${err.requestOptions.uri}',
      );
      buffer.writeln('║ Status: ${err.response?.statusCode}');
      buffer.writeln('║ Message: ${err.message}');
      if (err.response?.data != null) {
        buffer.writeln('║ Error Data: ${err.response?.data}');
      }
      buffer.writeln(
        '╚══════════════════════════════════════════════════════════',
      );
      _log(buffer.toString());
    }
    handler.next(err);
  }
}
