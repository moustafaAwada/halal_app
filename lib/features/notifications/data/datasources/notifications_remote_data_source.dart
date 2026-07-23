import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../models/notification_model.dart';

abstract class NotificationsRemoteDataSource {
  Future<List<NotificationModel>> getAllNotifications(int clientId);

  /// Despite the `/readed` path segment, the API returns **unread** items.
  Future<List<NotificationModel>> getUnreadNotifications(int clientId);

  /// Uses GET (not PATCH/PUT) to update read status per current backend contract.
  Future<String> markAsRead(int notificationId);
}

class NotificationsRemoteDataSourceImpl
    implements NotificationsRemoteDataSource {
  const NotificationsRemoteDataSourceImpl({
    required Dio dio,
    required DioErrorMapper errorMapper,
  })  : _dio = dio,
        _errorMapper = errorMapper;

  final Dio _dio;
  final DioErrorMapper _errorMapper;

  @override
  Future<List<NotificationModel>> getAllNotifications(int clientId) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiConstants.notificationsByClientId(clientId),
      );
      return _unwrapNotificationsList(response.data);
    } on DioException catch (e) {
      throw _errorMapper.mapToException(e);
    }
  }

  @override
  Future<List<NotificationModel>> getUnreadNotifications(int clientId) async {
    try {
      // Endpoint name is "readed" but response contains unread (read=false) items.
      final response = await _dio.get<dynamic>(
        ApiConstants.unreadNotificationsByClientId(clientId),
      );
      return _unwrapNotificationsList(response.data);
    } on DioException catch (e) {
      throw _errorMapper.mapToException(e);
    }
  }

  @override
  Future<String> markAsRead(int notificationId) async {
    try {
      // Backend uses GET to perform an update — keep method as documented.
      final response = await _dio.get<dynamic>(
        ApiConstants.markNotificationAsRead(notificationId),
      );
      return _unwrapSuccessMessage(response.data);
    } on DioException catch (e) {
      throw _errorMapper.mapToException(e);
    }
  }

  List<NotificationModel> _unwrapNotificationsList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map(
            (item) =>
                NotificationModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    }

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final inner = map['data'];
      if (inner is List) {
        return inner
            .whereType<Map>()
            .map(
              (item) =>
                  NotificationModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();
      }
    }

    return [];
  }

  String _unwrapSuccessMessage(dynamic data) {
    const fallback = 'تم تحديث حالة التنبيه بنجاح';

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final message = map['message']?.toString();
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }

    return fallback;
  }
}
