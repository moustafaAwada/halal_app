import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/trip.dart';
import '../repositories/trip_repository.dart';

class GetTripDetailsUseCase {
  const GetTripDetailsUseCase(this._repository);

  final TripRepository _repository;

  Future<Either<Failure, Trip>> call(int tripId) =>
      _repository.getTripDetails(tripId);
}
