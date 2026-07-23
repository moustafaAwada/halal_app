import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/notification_item.dart';
import '../repositories/notifications_repository.dart';

class GetUnreadNotificationsUseCase
    implements UseCase<List<NotificationItem>, GetUnreadNotificationsParams> {
  const GetUnreadNotificationsUseCase(this._repository);

  final NotificationsRepository _repository;

  @override
  Future<Either<Failure, List<NotificationItem>>> call(
    GetUnreadNotificationsParams params,
  ) {
    return _repository.getUnreadNotifications(params.clientId);
  }
}

class GetUnreadNotificationsParams extends Equatable {
  const GetUnreadNotificationsParams({required this.clientId});

  final int clientId;

  @override
  List<Object?> get props => [clientId];
}
