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
    if (failure is MultipleRestaurantsFailure) {
      return ServerException(
        message: failure.message,
        code: 'MULTIPLE_RESTAURANTS',
      );
    }
    return ServerException(message: failure.message);
  }

  Failure _mapResponseFailure(Response<dynamic>? response) {
    final statusCode = response?.statusCode;
    final message = _extractMessage(response?.data);
    final errorCode = _extractErrorCode(response?.data);

    if (statusCode == 400 && errorCode == 'MULTIPLE_RESTAURANTS') {
      return MultipleRestaurantsFailure(
        message: message ??
            'سلتك تحتوي على منتجات من مطعم آخر، هل ترغب في تفريغ السلة؟',
      );
    }

    return switch (statusCode) {
      400 => ServerFailure(message: message ?? 'البيانات المدخلة غير صحيحة'),
      401 => ServerFailure(message: message ?? 'بيانات الدخول غير صحيحة'),
      404 => ServerFailure(message: message ?? 'المستخدم غير موجود'),
      409 => ServerFailure(message: message ?? 'البريد الإلكتروني مستخدم بالفعل'),
      _ => ServerFailure(message: message ?? 'حدث خطأ في الخادم'),
    };
  }

  String? _extractMessage(dynamic data) {
    if (data is Map) {
      final message = Map<String, dynamic>.from(data)['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }
    return null;
  }

  String? _extractErrorCode(dynamic data) {
    if (data is Map) {
      final errorCode = Map<String, dynamic>.from(data)['error_code'];
      if (errorCode is String && errorCode.isNotEmpty) {
        return errorCode;
      }
    }
    return null;
  }
}
