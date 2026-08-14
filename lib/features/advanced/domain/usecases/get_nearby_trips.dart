import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../trip/domain/entities/trip.dart';
import '../repositories/advanced_features_repository.dart';

class GetNearbyTripsUseCase
    implements UseCase<List<Trip>, GetNearbyTripsParams> {
  const GetNearbyTripsUseCase(this._repository);

  final AdvancedFeaturesRepository _repository;

  @override
  Future<Either<Failure, List<Trip>>> call(GetNearbyTripsParams params) {
    return _repository.getNearbyTrips(params.lat, params.lng, params.radius);
  }
}

class GetNearbyTripsParams extends Equatable {
  const GetNearbyTripsParams({
    required this.lat,
    required this.lng,
    this.radius = 3,
  });

  final double lat;
  final double lng;
  final double radius;

  @override
  List<Object?> get props => [lat, lng, radius];
}
