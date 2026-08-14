import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../trip/domain/entities/trip.dart';
import '../../../trip/domain/entities/trip_status.dart';
import '../entities/eta_info.dart';

abstract class AdvancedFeaturesRepository {
  Future<Either<Failure, ETAInfo>> getHighDemandETA();

  Future<Either<Failure, Trip>> rebookTrip(int tripId);

  Future<Either<Failure, List<Trip>>> getNearbyTrips(
    double lat,
    double lng,
    double radius,
  );

  Future<Either<Failure, TripStatus>> startTrip(int tripId);

  /// Completes delivery. Pass [pin] for visa/card payments; omit for others.
  Future<Either<Failure, String>> verifyAndCompleteDelivery(
    int orderId, {
    String? pin,
  });
}
