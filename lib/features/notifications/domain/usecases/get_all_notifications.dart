import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/notification_item.dart';
import '../repositories/notifications_repository.dart';

class GetAllNotificationsUseCase
    implements UseCase<List<NotificationItem>, GetAllNotificationsParams> {
  const GetAllNotificationsUseCase(this._repository);

  final NotificationsRepository _repository;

  @override
  Future<Either<Failure, List<NotificationItem>>> call(
    GetAllNotificationsParams params,
  ) {
    return _repository.getAllNotifications(params.clientId);
  }
}

class GetAllNotificationsParams extends Equatable {
  const GetAllNotificationsParams({required this.clientId});

  final int clientId;

  @override
  List<Object?> get props => [clientId];
}
