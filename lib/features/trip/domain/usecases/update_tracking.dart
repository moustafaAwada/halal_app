import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/trip_tracking.dart';
import '../repositories/trip_repository.dart';

class UpdateTrackingUseCase
    implements UseCase<TripTracking, UpdateTrackingParams> {
  const UpdateTrackingUseCase(this._repository);

  final TripRepository _repository;

  @override
  Future<Either<Failure, TripTracking>> call(UpdateTrackingParams params) {
    return _repository.updateTracking(params.tripId, params.lat, params.lng);
  }
}

class UpdateTrackingParams extends Equatable {
  const UpdateTrackingParams({
    required this.tripId,
    required this.lat,
    required this.lng,
  });

  final int tripId;
  final double lat;
  final double lng;

  @override
  List<Object?> get props => [tripId, lat, lng];
}
