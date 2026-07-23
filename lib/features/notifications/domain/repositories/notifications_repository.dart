import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/notification_item.dart';

/// Contract for notification data operations.
abstract class NotificationsRepository {
  /// Returns all notifications for [clientId], newest first.
  Future<Either<Failure, List<NotificationItem>>> getAllNotifications(
    int clientId,
  );

  /// Returns unread notifications for [clientId] (`read == false`).
  ///
  /// Note: the backend route is `/notification/{clientId}/readed` but it
  /// intentionally returns **unread** items.
  Future<Either<Failure, List<NotificationItem>>> getUnreadNotifications(
    int clientId,
  );

  /// Marks a notification as read via `GET /notification/read/{notificationId}`.
  ///
  /// Returns the success message from the API when available.
  Future<Either<Failure, String>> markAsRead(int notificationId);
}
