import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/complete_trip_result.dart';
import '../repositories/trip_repository.dart';

class CompleteTripUseCase
    implements UseCase<CompleteTripResult, CompleteTripParams> {
  const CompleteTripUseCase(this._repository);

  final TripRepository _repository;

  @override
  Future<Either<Failure, CompleteTripResult>> call(CompleteTripParams params) {
    return _repository.completeTrip(params.tripId);
  }
}

class CompleteTripParams extends Equatable {
  const CompleteTripParams({required this.tripId});

  final int tripId;

  @override
  List<Object?> get props => [tripId];
}
