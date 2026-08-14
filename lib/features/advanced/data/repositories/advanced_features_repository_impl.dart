import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../trip/domain/entities/trip.dart';
import '../../../trip/domain/entities/trip_status.dart';
import '../../domain/entities/eta_info.dart';
import '../../domain/repositories/advanced_features_repository.dart';
import '../datasources/advanced_remote_data_source.dart';

class AdvancedFeaturesRepositoryImpl implements AdvancedFeaturesRepository {
  const AdvancedFeaturesRepositoryImpl({
    required AdvancedRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final AdvancedRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, ETAInfo>> getHighDemandETA() async {
    try {
      final result = await _remoteDataSource.getHighDemandETA();
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.message.isNotEmpty
              ? e.message
              : 'تعذر جلب وقت الوصول المتوقع',
        ),
      );
    } catch (_) {
      return const Left(
        ServerFailure(message: 'تعذر جلب وقت الوصول المتوقع'),
      );
    }
  }

  @override
  Future<Either<Failure, Trip>> rebookTrip(int tripId) async {
    try {
      final result = await _remoteDataSource.rebookTrip(tripId);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.message.isNotEmpty
              ? e.message
              : 'حدث خطأ أثناء إعادة الحجز',
        ),
      );
    } catch (_) {
      return const Left(
        ServerFailure(message: 'حدث خطأ أثناء إعادة الحجز'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Trip>>> getNearbyTrips(
    double lat,
    double lng,
    double radius,
  ) async {
    try {
      final result =
          await _remoteDataSource.getNearbyTrips(lat, lng, radius);
      return Right(result.map((trip) => trip.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.message.isNotEmpty
              ? e.message
              : 'تعذر جلب الرحلات القريبة',
        ),
      );
    } catch (_) {
      return const Left(
        ServerFailure(message: 'تعذر جلب الرحلات القريبة'),
      );
    }
  }

  @override
  Future<Either<Failure, TripStatus>> startTrip(int tripId) async {
    try {
      final status = await _remoteDataSource.startTrip(tripId);
      return Right(status);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.message.isNotEmpty
              ? e.message
              : 'حدث خطأ أثناء بدء الرحلة',
        ),
      );
    } catch (_) {
      return const Left(
        ServerFailure(message: 'حدث خطأ أثناء بدء الرحلة'),
      );
    }
  }

  @override
  Future<Either<Failure, String>> verifyAndCompleteDelivery(
    int orderId, {
    String? pin,
  }) async {
    try {
      final message = await _remoteDataSource.verifyAndCompleteDelivery(
        orderId,
        pin: pin,
      );
      return Right(message);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.message.isNotEmpty
              ? e.message
              : 'حدث خطأ أثناء تأكيد التسليم',
        ),
      );
    } catch (_) {
      return const Left(
        ServerFailure(message: 'حدث خطأ أثناء تأكيد التسليم'),
      );
    }
  }
}
