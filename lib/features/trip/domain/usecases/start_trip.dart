import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/trip_status.dart';
import '../repositories/trip_repository.dart';

class StartTripUseCase implements UseCase<TripStatus, StartTripParams> {
  const StartTripUseCase(this._repository);

  final TripRepository _repository;

  @override
  Future<Either<Failure, TripStatus>> call(StartTripParams params) {
    return _repository.startTrip(params.tripId);
  }
}

class StartTripParams extends Equatable {
  const StartTripParams({required this.tripId});

  final int tripId;

  @override
  List<Object?> get props => [tripId];
}
