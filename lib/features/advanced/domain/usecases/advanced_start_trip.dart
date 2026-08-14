import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../trip/domain/entities/trip_status.dart';
import '../repositories/advanced_features_repository.dart';

/// Driver-side start trip (waiting-fee aware endpoint).
class AdvancedStartTripUseCase
    implements UseCase<TripStatus, AdvancedStartTripParams> {
  const AdvancedStartTripUseCase(this._repository);

  final AdvancedFeaturesRepository _repository;

  @override
  Future<Either<Failure, TripStatus>> call(AdvancedStartTripParams params) {
    return _repository.startTrip(params.tripId);
  }
}

class AdvancedStartTripParams extends Equatable {
  const AdvancedStartTripParams({required this.tripId});

  final int tripId;

  @override
  List<Object?> get props => [tripId];
}
