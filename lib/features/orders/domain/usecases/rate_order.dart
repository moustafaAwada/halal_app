import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/rating.dart';
import '../repositories/rating_repository.dart';

class RateOrderUseCase implements UseCase<Rating, RateOrderParams> {
  const RateOrderUseCase(this._repository);

  final RatingRepository _repository;

  @override
  Future<Either<Failure, Rating>> call(RateOrderParams params) {
    return _repository.rateOrder(
      params.orderId,
      params.ratingValue,
      params.comment,
    );
  }
}

class RateOrderParams extends Equatable {
  const RateOrderParams({
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
