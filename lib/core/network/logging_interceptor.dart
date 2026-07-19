import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';

/// Logs HTTP requests, responses, and errors for debugging.
class LoggingInterceptor extends Interceptor {
  static const _tag = 'API';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final buffer = StringBuffer()
      ..writeln('┌── REQUEST ─────────────────────────────────')
      ..writeln('│ ${options.method} ${options.uri}')
      ..writeln('│ Headers: ${_prettyJson(options.headers)}');

    if (options.queryParameters.isNotEmpty) {
      buffer.writeln('│ Query: ${_prettyJson(options.queryParameters)}');
    }

    if (options.data != null) {
      buffer.writeln('│ Body: ${_prettyJson(options.data)}');
    }

    buffer.writeln('└────────────────────────────────────────────');
    developer.log(buffer.toString(), name: _tag);

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final buffer = StringBuffer()
      ..writeln('┌── RESPONSE ────────────────────────────────')
      ..writeln(
        '│ ${response.statusCode} ${response.requestOptions.method} '
        '${response.requestOptions.uri}',
      )
      ..writeln('│ Data: ${_prettyJson(response.data)}')
      ..writeln('└────────────────────────────────────────────');
    developer.log(buffer.toString(), name: _tag);

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final buffer = StringBuffer()
      ..writeln('┌── ERROR ───────────────────────────────────')
      ..writeln(
        '│ ${err.response?.statusCode ?? '-'} ${err.requestOptions.method} '
        '${err.requestOptions.uri}',
      )
      ..writeln('│ Type: ${err.type}')
      ..writeln('│ Message: ${err.message}');

    if (err.response?.data != null) {
      buffer.writeln('│ Data: ${_prettyJson(err.response?.data)}');
    }

    buffer.writeln('└────────────────────────────────────────────');
    developer.log(buffer.toString(), name: _tag);

    handler.next(err);
  }

  String _prettyJson(dynamic data) {
    try {
      if (data is Map || data is List) {
        return const JsonEncoder.withIndent('  ').convert(data);
      }
      if (data is String) {
        final decoded = jsonDecode(data);
        return const JsonEncoder.withIndent('  ').convert(decoded);
      }
      return data.toString();
    } catch (_) {
      return data.toString();
    }
  }
}
