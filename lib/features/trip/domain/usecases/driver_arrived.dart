import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/trip_status.dart';
import '../repositories/trip_repository.dart';

class DriverArrivedUseCase implements UseCase<TripStatus, DriverArrivedParams> {
  const DriverArrivedUseCase(this._repository);

  final TripRepository _repository;

  @override
  Future<Either<Failure, TripStatus>> call(DriverArrivedParams params) {
    return _repository.driverArrived(params.tripId);
  }
}

class DriverArrivedParams extends Equatable {
  const DriverArrivedParams({required this.tripId});

  final int tripId;

  @override
  List<Object?> get props => [tripId];
}
