import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/complete_trip_result.dart';
import '../../domain/entities/trip.dart';
import '../../domain/entities/trip_status.dart';
import '../../domain/entities/trip_tracking.dart';
import '../../domain/repositories/trip_repository.dart';
import '../datasources/trip_remote_data_source.dart';

class TripRepositoryImpl implements TripRepository {
  const TripRepositoryImpl({
    required TripRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final TripRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, Trip>> requestTrip(Map<String, dynamic> data) async {
    try {
      final result = await _remoteDataSource.requestTrip(data);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.message.isNotEmpty
              ? e.message
              : 'حدث خطأ أثناء طلب الرحلة',
        ),
      );
    } catch (_) {
      return const Left(
        ServerFailure(message: 'حدث خطأ أثناء طلب الرحلة'),
      );
    }
  }

  @override
  Future<Either<Failure, TripStatus>> acceptTrip(int tripId) async {
    try {
      final status = await _remoteDataSource.acceptTrip(tripId);
      return Right(status);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.message.isNotEmpty ? e.message : 'حدث خطأ أثناء قبول الرحلة',
        ),
      );
    } catch (_) {
      return const Left(
        ServerFailure(message: 'حدث خطأ أثناء قبول الرحلة'),
      );
    }
  }

  @override
  Future<Either<Failure, TripStatus>> driverArrived(int tripId) async {
    try {
      final status = await _remoteDataSource.driverArrived(tripId);
      return Right(status);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.message.isNotEmpty
              ? e.message
              : 'حدث خطأ أثناء تسجيل وصول السائق',
        ),
      );
    } catch (_) {
      return const Left(
        ServerFailure(message: 'حدث خطأ أثناء تسجيل وصول السائق'),
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
  Future<Either<Failure, TripTracking>> updateTracking(
    int tripId,
    double lat,
    double lng,
  ) async {
    try {
      final result =
          await _remoteDataSource.updateTracking(tripId, lat, lng);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.message.isNotEmpty
              ? e.message
              : 'حدث خطأ أثناء تحديث الموقع',
        ),
      );
    } catch (_) {
      return const Left(
        ServerFailure(message: 'حدث خطأ أثناء تحديث الموقع'),
      );
    }
  }

  @override
  Future<Either<Failure, CompleteTripResult>> completeTrip(int tripId) async {
    try {
      final result = await _remoteDataSource.completeTrip(tripId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.message.isNotEmpty
              ? e.message
              : 'حدث خطأ أثناء إنهاء الرحلة',
        ),
      );
    } catch (_) {
      return const Left(
        ServerFailure(message: 'حدث خطأ أثناء إنهاء الرحلة'),
      );
    }
  }

  @override
  Future<Either<Failure, String>> cancelTrip(
    int tripId,
    String reason,
    String cancelledBy,
  ) async {
    try {
      final message =
          await _remoteDataSource.cancelTrip(tripId, reason, cancelledBy);
      return Right(message);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.message.isNotEmpty
              ? e.message
              : 'حدث خطأ أثناء إلغاء الرحلة',
        ),
      );
    } catch (_) {
      return const Left(
        ServerFailure(message: 'حدث خطأ أثناء إلغاء الرحلة'),
      );
    }
  }

  @override
  Future<Either<Failure, String>> rateTrip(
    int tripId,
    Map<String, dynamic> data,
  ) async {
    try {
      final message = await _remoteDataSource.rateTrip(tripId, data);
      return Right(message);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.message.isNotEmpty
              ? e.message
              : 'حدث خطأ أثناء التقييم',
        ),
      );
    } catch (_) {
      return const Left(
        ServerFailure(message: 'حدث خطأ أثناء التقييم'),
      );
    }
  }
}
