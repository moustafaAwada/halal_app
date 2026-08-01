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
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: _asInt(json['id']) ?? 0,
      status: TripStatus.fromApi(json['status']?.toString()),
      pickupLat: _asDouble(json['pickupLat']),
      pickupLng: _asDouble(json['pickupLng']),
      pickupAddress: json['pickupAddress']?.toString(),
      dropoffLat: _asDouble(json['dropoffLat']),
      dropoffLng: _asDouble(json['dropoffLng']),
      dropoffAddress: json['dropoffAddress']?.toString(),
      vehicleType: json['vehicleType']?.toString(),
      paymentMethod: json['paymentMethod']?.toString(),
      fareAmount: _asDouble(json['fareAmount']),
      distanceKm: _asDouble(json['distanceKm']),
      durationMinutes: _asInt(json['durationMinutes']),
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
      );

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
