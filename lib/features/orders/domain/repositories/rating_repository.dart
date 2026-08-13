import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/rating.dart';

abstract class RatingRepository {
  Future<Either<Failure, Rating>> rateOrder(
    int orderId,
    int ratingValue,
    String? comment,
  );

  Future<Either<Failure, Rating>> rateDelivery(
    int orderId,
    int ratingValue,
    String? comment,
  );
}
