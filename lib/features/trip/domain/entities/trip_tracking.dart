import 'package:equatable/equatable.dart';

class TripTracking extends Equatable {
  const TripTracking({
    required this.tripId,
    required this.lat,
    required this.lng,
    this.recordedAt,
  });

  final int tripId;
  final double lat;
  final double lng;
  final DateTime? recordedAt;

  @override
  List<Object?> get props => [tripId, lat, lng, recordedAt];
}
