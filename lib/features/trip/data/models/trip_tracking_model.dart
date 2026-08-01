import '../../domain/entities/trip_tracking.dart';

class TripTrackingModel extends TripTracking {
  const TripTrackingModel({
    required super.tripId,
    required super.lat,
    required super.lng,
    super.recordedAt,
  });

  factory TripTrackingModel.fromJson(Map<String, dynamic> json) {
    return TripTrackingModel(
      tripId: _asInt(json['tripId']) ?? 0,
      lat: _asDouble(json['lat']),
      lng: _asDouble(json['lng']),
      recordedAt: _asDateTime(json['recordedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tripId': tripId,
      'lat': lat,
      'lng': lng,
      if (recordedAt != null) 'recordedAt': recordedAt!.toIso8601String(),
    };
  }

  TripTracking toEntity() => TripTracking(
        tripId: tripId,
        lat: lat,
        lng: lng,
        recordedAt: recordedAt,
      );

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime? _asDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
