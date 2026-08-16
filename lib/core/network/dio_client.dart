import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';
import '../storage/secure_storage_service.dart';
import 'auth_interceptor.dart';
import 'logging_interceptor.dart';

/// Configured Dio HTTP client for the application API.
class DioClient {
  DioClient({
    SecureStorageService? secureStorage,
    void Function()? onSessionExpired,
  }) : _dio = Dio(
          BaseOptions(
            baseUrl: ApiConstants.clientBaseUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        ) {
    if (secureStorage != null) {
      _dio.interceptors.add(
        AuthInterceptor(
          dio: _dio,
          secureStorage: secureStorage,
          onSessionExpired: onSessionExpired,
        ),
      );
    }

    // Log all requests/responses in debug builds only.
    if (kDebugMode) {
      _dio.interceptors.add(LoggingInterceptor());
    }
  }

  final Dio _dio;

  Dio get dio => _dio;
}
