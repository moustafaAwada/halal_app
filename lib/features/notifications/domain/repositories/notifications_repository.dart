import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/notification_item.dart';

abstract class NotificationsRepository {
  Future<Either<Failure, List<NotificationItem>>> getAllNotifications(
    int clientId,
  );


  Future<Either<Failure, List<NotificationItem>>> getUnreadNotifications(
    int clientId,
  );


  Future<Either<Failure, String>> markAsRead(int notificationId);
}
