import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/driver_info.dart';
import '../../domain/entities/trip.dart';
import '../../domain/entities/trip_status.dart';
import 'driver_info_model.dart';

class TripModel extends Trip {
  const TripModel({
    required super.id,
    required super.status,
    super.pickupLat,
    super.pickupLng,
    super.pickupAddress,
    super.dropoffLat,
    super.dropoffLng,
    super.dropoffAddress,
    super.vehicleType,
    super.paymentMethod,
    super.fareAmount,
    super.distanceKm,
    super.durationMinutes,
    super.isPrebooking,
    super.prebookingTime,
    super.driver,
  });

  /// Parses a trip from JSON.
  ///
  /// IMPORTANT: `distanceKm` and `fareAmount` are returned as strings from
  /// the API (e.g. `"1.71"`, `"29.00"`). [_safeDouble] handles both
  /// `String` and `num` types without throwing.
  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: JsonParsers.toInt(json['id']),
      status: TripStatus.fromApi(json['status']?.toString()),
      pickupLat: _safeDouble(json['pickupLat'] ?? json['pickup_lat']),
      pickupLng: _safeDouble(json['pickupLng'] ?? json['pickup_lng']),
      pickupAddress: json['pickupAddress']?.toString() ??
          json['pickup_address']?.toString(),
      dropoffLat: _safeDouble(json['dropoffLat'] ?? json['dropoff_lat']),
      dropoffLng: _safeDouble(json['dropoffLng'] ?? json['dropoff_lng']),
      dropoffAddress: json['dropoffAddress']?.toString() ??
          json['dropoff_address']?.toString(),
      // Top-level vehicleType is still present on some endpoints; the delivery
      // object is the authoritative source for the assigned trip.
      vehicleType: json['vehicleType']?.toString() ??
          json['vehicle_type']?.toString(),
      paymentMethod: json['paymentMethod']?.toString() ??
          json['payment_method']?.toString(),
      // CRITICAL: fareAmount and distanceKm arrive as Strings from the API.
      fareAmount: _safeDouble(json['fareAmount'] ?? json['fare_amount']),
      distanceKm: _safeDouble(json['distanceKm'] ?? json['distance_km']),
      durationMinutes: _safeInt(
        json['durationMinutes'] ?? json['duration_minutes'],
      ),
      isPrebooking: JsonParsers.toBool(
        json['is_prebooking'] ?? json['isPrebooking'],
      ),
      prebookingTime: _safeDateTime(
        json['prebooking_time'] ?? json['prebookingTime'],
      ),
      // Parse the nested delivery object into a DriverInfo entity.
      driver: _parseDriver(json['delivery']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status.apiValue,
      if (pickupLat != null) 'pickupLat': pickupLat,
      if (pickupLng != null) 'pickupLng': pickupLng,
      if (pickupAddress != null) 'pickupAddress': pickupAddress,
      if (dropoffLat != null) 'dropoffLat': dropoffLat,
      if (dropoffLng != null) 'dropoffLng': dropoffLng,
      if (dropoffAddress != null) 'dropoffAddress': dropoffAddress,
      if (vehicleType != null) 'vehicleType': vehicleType,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      if (fareAmount != null) 'fareAmount': fareAmount,
      if (distanceKm != null) 'distanceKm': distanceKm,
      if (durationMinutes != null) 'durationMinutes': durationMinutes,
      'is_prebooking': isPrebooking,
      if (prebookingTime != null)
        'prebooking_time': _toApiDateTime(prebookingTime!),
    };
  }

  Trip toEntity() => Trip(
        id: id,
        status: status,
        pickupLat: pickupLat,
        pickupLng: pickupLng,
        pickupAddress: pickupAddress,
        dropoffLat: dropoffLat,
        dropoffLng: dropoffLng,
        dropoffAddress: dropoffAddress,
        vehicleType: vehicleType,
        paymentMethod: paymentMethod,
        fareAmount: fareAmount,
        distanceKm: distanceKm,
        durationMinutes: durationMinutes,
        isPrebooking: isPrebooking,
        prebookingTime: prebookingTime,
        driver: driver,
      );

  // ─── Private parsers ─────────────────────────────────────────────────────────

  /// Safely parses a value to [double], handling both [String] and [num].
  /// Returns `null` if the value is null, empty, or unparseable.
  static double? _safeDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      return double.tryParse(trimmed);
    }
    return null;
  }

  static int? _safeInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final trimmed = value.trim();
      return int.tryParse(trimmed) ?? double.tryParse(trimmed)?.toInt();
    }
    return null;
  }

  static DateTime? _safeDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  /// Parses the nested `delivery` map into a [DriverInfo] entity.
  /// Returns `null` if the delivery key is absent or not a map.
  static DriverInfo? _parseDriver(dynamic delivery) {
    if (delivery is! Map) return null;
    try {
      return DriverInfoModel.fromJson(
        Map<String, dynamic>.from(delivery),
      ).toEntity();
    } catch (_) {
      return null;
    }
  }

  static String _toApiDateTime(DateTime value) {
    final iso = value.toUtc().toIso8601String();
    if (iso.endsWith('Z')) return iso;
    if (iso.endsWith('+00:00')) {
      return '${iso.substring(0, iso.length - 6)}Z';
    }
    return '${iso}Z';
  }
}
