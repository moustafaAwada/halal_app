import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notifications_repository.dart';

class MarkNotificationAsReadUseCase
    implements UseCase<String, MarkNotificationAsReadParams> {
  const MarkNotificationAsReadUseCase(this._repository);

  final NotificationsRepository _repository;

  @override
  Future<Either<Failure, String>> call(MarkNotificationAsReadParams params) {
    return _repository.markAsRead(params.notificationId);
  }
}

class MarkNotificationAsReadParams extends Equatable {
  const MarkNotificationAsReadParams({required this.notificationId});

  final int notificationId;

  @override
  List<Object?> get props => [notificationId];
}
