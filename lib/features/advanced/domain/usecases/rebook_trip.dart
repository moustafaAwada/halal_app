import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../trip/domain/entities/trip.dart';
import '../repositories/advanced_features_repository.dart';

class RebookTripUseCase implements UseCase<Trip, RebookTripParams> {
  const RebookTripUseCase(this._repository);

  final AdvancedFeaturesRepository _repository;

  @override
  Future<Either<Failure, Trip>> call(RebookTripParams params) {
    return _repository.rebookTrip(params.tripId);
  }
}

class RebookTripParams extends Equatable {
  const RebookTripParams({required this.tripId});

  final int tripId;

  @override
  List<Object?> get props => [tripId];
}
