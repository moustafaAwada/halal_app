import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/trip_repository.dart';

class CancelTripUseCase implements UseCase<String, CancelTripParams> {
  const CancelTripUseCase(this._repository);

  final TripRepository _repository;

  @override
  Future<Either<Failure, String>> call(CancelTripParams params) {
    return _repository.cancelTrip(
      params.tripId,
      params.reason,
      params.cancelledBy,
    );
  }
}

class CancelTripParams extends Equatable {
  const CancelTripParams({
    required this.tripId,
    required this.reason,
    this.cancelledBy = 'customer',
  });

  final int tripId;
  final String reason;
  final String cancelledBy;

  @override
  List<Object?> get props => [tripId, reason, cancelledBy];
}
