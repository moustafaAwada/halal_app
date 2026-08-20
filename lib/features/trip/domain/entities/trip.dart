import 'package:equatable/equatable.dart';

import 'driver_info.dart';
import 'trip_status.dart';

class Trip extends Equatable {
  const Trip({
    required this.id,
    required this.status,
    this.pickupLat,
    this.pickupLng,
    this.pickupAddress,
    this.dropoffLat,
    this.dropoffLng,
    this.dropoffAddress,
    this.vehicleType,
    this.paymentMethod,
    this.fareAmount,
    this.distanceKm,
    this.durationMinutes,
    this.isPrebooking = false,
    this.prebookingTime,
    this.driver,
  });

  final int id;
  final TripStatus status;
  final double? pickupLat;
  final double? pickupLng;
  final String? pickupAddress;
  final double? dropoffLat;
  final double? dropoffLng;
  final String? dropoffAddress;
  final String? vehicleType;
  final String? paymentMethod;
  final double? fareAmount;
  final double? distanceKm;
  final int? durationMinutes;
  final bool isPrebooking;
  final DateTime? prebookingTime;

  /// Driver information populated when a driver has been assigned to the trip.
  /// Null while the trip is in the `requested` (searching) state.
  final DriverInfo? driver;

  Trip copyWith({
    int? id,
    TripStatus? status,
    double? pickupLat,
    double? pickupLng,
    String? pickupAddress,
    double? dropoffLat,
    double? dropoffLng,
    String? dropoffAddress,
    String? vehicleType,
    String? paymentMethod,
    double? fareAmount,
    double? distanceKm,
    int? durationMinutes,
    bool? isPrebooking,
    DateTime? prebookingTime,
    DriverInfo? driver,
  }) {
    return Trip(
      id: id ?? this.id,
      status: status ?? this.status,
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLng: pickupLng ?? this.pickupLng,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffLat: dropoffLat ?? this.dropoffLat,
      dropoffLng: dropoffLng ?? this.dropoffLng,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      vehicleType: vehicleType ?? this.vehicleType,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      fareAmount: fareAmount ?? this.fareAmount,
      distanceKm: distanceKm ?? this.distanceKm,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isPrebooking: isPrebooking ?? this.isPrebooking,
      prebookingTime: prebookingTime ?? this.prebookingTime,
      driver: driver ?? this.driver,
    );
  }

  @override
  List<Object?> get props => [
        id,
        status,
        pickupLat,
        pickupLng,
        pickupAddress,
        dropoffLat,
        dropoffLng,
        dropoffAddress,
        vehicleType,
        paymentMethod,
        fareAmount,
        distanceKm,
        durationMinutes,
        isPrebooking,
        prebookingTime,
        driver,
      ];
}
