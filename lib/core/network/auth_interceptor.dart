import 'dart:async';

import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../storage/secure_storage_service.dart';

/// Attaches the stored auth token and renews it on 401 responses.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required Dio dio,
    required SecureStorageService secureStorage,
    void Function()? onSessionExpired,
  })  : _dio = dio,
        _secureStorage = secureStorage,
        _onSessionExpired = onSessionExpired;

  final Dio _dio;
  final SecureStorageService _secureStorage;
  final void Function()? _onSessionExpired;

  static const _retriedKey = 'retried';

  static const _skipRefreshPaths = {
    ApiConstants.login,
    ApiConstants.register,
    ApiConstants.sendCode,
    ApiConstants.forgetPassword,
    ApiConstants.refreshToken,
  };

  Completer<String?>? _refreshCompleter;

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

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    final path = err.requestOptions.path;
    if (_shouldSkipRefresh(path) ||
        err.requestOptions.extra[_retriedKey] == true) {
      handler.next(err);
      return;
    }

    try {
      final newToken = await _refreshToken();
      if (newToken == null || newToken.isEmpty) {
        await _forceLogout();
        handler.next(err);
        return;
      }

      final requestOptions = err.requestOptions;
      requestOptions.headers['Authorization'] = 'Bearer $newToken';
      requestOptions.extra[_retriedKey] = true;

      final response = await _dio.fetch<dynamic>(requestOptions);
      handler.resolve(response);
    } on DioException catch (e) {
      await _forceLogout();
      handler.next(e);
    } catch (_) {
      await _forceLogout();
      handler.next(err);
    }
  }

  bool _shouldSkipRefresh(String path) {
    final normalized = path.split('?').first;
    for (final skip in _skipRefreshPaths) {
      if (normalized == skip || normalized.endsWith(skip)) {
        return true;
      }
    }
    return false;
  }

  Future<String?> _refreshToken() async {
    final inFlight = _refreshCompleter;
    if (inFlight != null) {
      return inFlight.future;
    }

    final completer = Completer<String?>();
    _refreshCompleter = completer;

    try {
      final currentToken = await _secureStorage.getToken();
      if (currentToken == null || currentToken.isEmpty) {
        completer.complete(null);
        return null;
      }

      final refreshDio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.clientBaseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: const {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      final response = await refreshDio.post<dynamic>(
        ApiConstants.refreshToken,
        data: {'token': currentToken},
      );

      final newToken = _extractToken(response.data);
      if (newToken != null && newToken.isNotEmpty) {
        await _secureStorage.saveToken(newToken);
        completer.complete(newToken);
        return newToken;
      }

      completer.complete(null);
      return null;
    } catch (_) {
      completer.complete(null);
      return null;
    } finally {
      _refreshCompleter = null;
    }
  }

  String? _extractToken(dynamic data) {
    if (data is! Map) return null;
    final map = Map<String, dynamic>.from(data);

    final direct = map['token'];
    if (direct is String && direct.isNotEmpty) return direct;

    final nested = map['data'];
    if (nested is Map) {
      final nestedMap = Map<String, dynamic>.from(nested);
      final nestedToken = nestedMap['token'];
      if (nestedToken is String && nestedToken.isNotEmpty) return nestedToken;
    }

    return null;
  }

  Future<void> _forceLogout() async {
    await _secureStorage.deleteToken();
    await _secureStorage.deleteUserId();
    _onSessionExpired?.call();
  }
}
