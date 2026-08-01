import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/trip_repository.dart';

class RateTripUseCase implements UseCase<String, RateTripParams> {
  const RateTripUseCase(this._repository);

  final TripRepository _repository;

  @override
  Future<Either<Failure, String>> call(RateTripParams params) {
    return _repository.rateTrip(params.tripId, params.data);
  }
}

class RateTripParams extends Equatable {
  const RateTripParams({
    required this.tripId,
    required this.data,
  });

  final int tripId;
  final Map<String, dynamic> data;

  @override
  List<Object?> get props => [tripId, data];
}
