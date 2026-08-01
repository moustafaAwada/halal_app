import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/trip.dart';
import '../repositories/trip_repository.dart';

class RequestTripUseCase implements UseCase<Trip, RequestTripParams> {
  const RequestTripUseCase(this._repository);

  final TripRepository _repository;

  @override
  Future<Either<Failure, Trip>> call(RequestTripParams params) {
    return _repository.requestTrip(params.data);
  }
}

class RequestTripParams extends Equatable {
  const RequestTripParams({required this.data});

  final Map<String, dynamic> data;

  @override
  List<Object?> get props => [data];
}
