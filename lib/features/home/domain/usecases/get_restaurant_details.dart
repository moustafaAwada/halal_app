import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/restaurant_detail.dart';
import '../repositories/home_repository.dart';

class GetRestaurantDetailsUseCase
    implements UseCase<RestaurantDetail, RestaurantDetailsParams> {
  const GetRestaurantDetailsUseCase(this._repository);

  final HomeRepository _repository;

  @override
  Future<Either<Failure, RestaurantDetail>> call(
    RestaurantDetailsParams params,
  ) {
    return _repository.getRestaurantDetails(params.vendorId);
  }
}

class RestaurantDetailsParams extends Equatable {
  const RestaurantDetailsParams({required this.vendorId});

  final int vendorId;

  @override
  List<Object?> get props => [vendorId];
}
