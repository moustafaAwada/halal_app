import 'package:dio/dio.dart';

import '../error/exceptions.dart';
import '../error/failures.dart';

class DioErrorMapper {
  const DioErrorMapper();

  Failure mapToFailure(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkFailure(message: 'لا يوجد اتصال بالإنترنت');
      case DioExceptionType.badResponse:
        return _mapResponseFailure(exception.response);
      default:
        return const ServerFailure(message: 'حدث خطأ غير متوقع');
    }
  }

  ServerException mapToException(DioException exception) {
    final failure = mapToFailure(exception);
    return ServerException(message: failure.message);
  }

  Failure _mapResponseFailure(Response<dynamic>? response) {
    final statusCode = response?.statusCode;
    final message = _extractMessage(response?.data);

    return switch (statusCode) {
      400 => ServerFailure(message: message ?? 'البيانات المدخلة غير صحيحة'),
      401 => ServerFailure(message: message ?? 'بيانات الدخول غير صحيحة'),
      404 => ServerFailure(message: message ?? 'المستخدم غير موجود'),
      409 => ServerFailure(message: message ?? 'البريد الإلكتروني مستخدم بالفعل'),
      _ => ServerFailure(message: message ?? 'حدث خطأ في الخادم'),
    };
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }
    return null;
  }
}
