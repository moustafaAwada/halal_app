import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/trip_status.dart';
import '../repositories/trip_repository.dart';

class AcceptTripUseCase implements UseCase<TripStatus, AcceptTripParams> {
  const AcceptTripUseCase(this._repository);

  final TripRepository _repository;

  @override
  Future<Either<Failure, TripStatus>> call(AcceptTripParams params) {
    return _repository.acceptTrip(params.tripId);
  }
}

class AcceptTripParams extends Equatable {
  const AcceptTripParams({required this.tripId});

  final int tripId;

  @override
  List<Object?> get props => [tripId];
}
