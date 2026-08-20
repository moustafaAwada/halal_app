import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/ad.dart';
import '../../domain/repositories/ads_repository.dart';
import '../datasources/ads_remote_data_source.dart';

class AdsRepositoryImpl implements AdsRepository {
  const AdsRepositoryImpl({required AdsRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final AdsRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<Ad>>> getAvailableAds() async {
    try {
      final result = await _remoteDataSource.getAvailableAds();
      return Right(result.map((item) => item.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.message.isNotEmpty
              ? e.message
              : 'حدث خطأ أثناء جلب الإعلانات',
        ),
      );
    } catch (_) {
      return const Left(
        ServerFailure(message: 'حدث خطأ أثناء جلب الإعلانات'),
      );
    }
  }
}
