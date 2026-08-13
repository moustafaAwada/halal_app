import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/trip.dart';
import '../../domain/entities/trip_status.dart';

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
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: JsonParsers.toInt(json['id']),
      status: TripStatus.fromApi(json['status']?.toString()),
      pickupLat: _asNullableDouble(json['pickupLat']),
      pickupLng: _asNullableDouble(json['pickupLng']),
      pickupAddress: json['pickupAddress']?.toString(),
      dropoffLat: _asNullableDouble(json['dropoffLat']),
      dropoffLng: _asNullableDouble(json['dropoffLng']),
      dropoffAddress: json['dropoffAddress']?.toString(),
      vehicleType: json['vehicleType']?.toString(),
      paymentMethod: json['paymentMethod']?.toString(),
      fareAmount: _asNullableDouble(json['fareAmount']),
      distanceKm: _asNullableDouble(json['distanceKm']),
      durationMinutes: _asNullableInt(json['durationMinutes']),
      isPrebooking: JsonParsers.toBool(
        json['is_prebooking'] ?? json['isPrebooking'],
      ),
      prebookingTime: _asDateTime(
        json['prebooking_time'] ?? json['prebookingTime'],
      ),
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
      );

  static double? _asNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _asNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? double.tryParse(value)?.toInt();
    }
    return null;
  }

  static DateTime? _asDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
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
