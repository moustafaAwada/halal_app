import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/rating.dart';
import '../repositories/rating_repository.dart';

class RateDeliveryUseCase implements UseCase<Rating, RateDeliveryParams> {
  const RateDeliveryUseCase(this._repository);

  final RatingRepository _repository;

  @override
  Future<Either<Failure, Rating>> call(RateDeliveryParams params) {
    return _repository.rateDelivery(
      params.orderId,
      params.ratingValue,
      params.comment,
    );
  }
}

class RateDeliveryParams extends Equatable {
  const RateDeliveryParams({
    required this.orderId,
    required this.ratingValue,
    this.comment,
  });

  final int orderId;
  final int ratingValue;
  final String? comment;

  @override
  List<Object?> get props => [orderId, ratingValue, comment];
}
