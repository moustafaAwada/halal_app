import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/notification_item.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_remote_data_source.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  const NotificationsRepositoryImpl({
    required NotificationsRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final NotificationsRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<NotificationItem>>> getAllNotifications(
    int clientId,
  ) async {
    try {
      final result = await _remoteDataSource.getAllNotifications(clientId);
      return Right(result.map((item) => item.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.message.isNotEmpty
              ? e.message
              : 'حدث خطأ أثناء جلب التنبيهات',
        ),
      );
    } catch (_) {
      return const Left(
        ServerFailure(message: 'حدث خطأ أثناء جلب التنبيهات'),
      );
    }
  }

  @override
  Future<Either<Failure, List<NotificationItem>>> getUnreadNotifications(
    int clientId,
  ) async {
    try {
      final result = await _remoteDataSource.getUnreadNotifications(clientId);
      return Right(result.map((item) => item.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.message.isNotEmpty
              ? e.message
              : 'حدث خطأ أثناء جلب التنبيهات',
        ),
      );
    } catch (_) {
      return const Left(
        ServerFailure(message: 'حدث خطأ أثناء جلب التنبيهات'),
      );
    }
  }

  @override
  Future<Either<Failure, String>> markAsRead(int notificationId) async {
    try {
      final message = await _remoteDataSource.markAsRead(notificationId);
      return Right(message);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.message.isNotEmpty
              ? e.message
              : 'حدث خطأ أثناء تحديث حالة التنبيه',
        ),
      );
    } catch (_) {
      return const Left(
        ServerFailure(message: 'حدث خطأ أثناء تحديث حالة التنبيه'),
      );
    }
  }
}
