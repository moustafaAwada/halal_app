import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/rating.dart';
import '../../domain/repositories/rating_repository.dart';
import '../datasources/rating_remote_data_source.dart';

class RatingRepositoryImpl implements RatingRepository {
  const RatingRepositoryImpl({
    required RatingRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final RatingRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, Rating>> rateOrder(
    int orderId,
    int ratingValue,
    String? comment,
  ) async {
    try {
      final result = await _remoteDataSource.rateOrder(
        orderId,
        ratingValue,
        comment,
      );
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.message.isNotEmpty
              ? e.message
              : 'حدث خطأ أثناء تقييم الطلب',
        ),
      );
    } catch (_) {
      return const Left(
        ServerFailure(message: 'حدث خطأ أثناء تقييم الطلب'),
      );
    }
  }

  @override
  Future<Either<Failure, Rating>> rateDelivery(
    int orderId,
    int ratingValue,
    String? comment,
  ) async {
    try {
      final result = await _remoteDataSource.rateDelivery(
        orderId,
        ratingValue,
        comment,
      );
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.message.isNotEmpty
              ? e.message
              : 'حدث خطأ أثناء تقييم المندوب',
        ),
      );
    } catch (_) {
      return const Left(
        ServerFailure(message: 'حدث خطأ أثناء تقييم المندوب'),
      );
    }
  }
}
