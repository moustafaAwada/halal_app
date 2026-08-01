import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/complete_trip_result.dart';
import '../entities/trip.dart';
import '../entities/trip_status.dart';
import '../entities/trip_tracking.dart';

abstract class TripRepository {
  Future<Either<Failure, Trip>> requestTrip(Map<String, dynamic> data);

  Future<Either<Failure, TripStatus>> acceptTrip(int tripId);

  Future<Either<Failure, TripStatus>> driverArrived(int tripId);

  Future<Either<Failure, TripStatus>> startTrip(int tripId);

  Future<Either<Failure, TripTracking>> updateTracking(
    int tripId,
    double lat,
    double lng,
  );

  Future<Either<Failure, CompleteTripResult>> completeTrip(int tripId);

  Future<Either<Failure, String>> cancelTrip(
    int tripId,
    String reason,
    String cancelledBy,
  );

  Future<Either<Failure, String>> rateTrip(
    int tripId,
    Map<String, dynamic> data,
  );
}
