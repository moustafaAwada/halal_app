import 'package:dio/dio.dart';

import '../storage/secure_storage_service.dart';

/// Attaches the stored auth token to outgoing requests.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required SecureStorageService secureStorage})
      : _secureStorage = secureStorage;

  final SecureStorageService _secureStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
