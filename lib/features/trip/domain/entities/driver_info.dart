import 'package:equatable/equatable.dart';

/// Represents the driver (delivery person) assigned to a trip.
/// Maps to the nested `delivery` object in the API response.
class DriverInfo extends Equatable {
  const DriverInfo({
    required this.name,
    this.phone,
    this.vehicleType,
    this.plateNumber,
    this.vehicleColor,
  });

  /// Driver's full name from `delivery.user.name`.
  final String name;

  /// Driver's phone number from `delivery.phone`.
  final String? phone;

  /// Vehicle type (e.g. "car", "motorcycle") from `delivery.vehicleType`.
  final String? vehicleType;

  /// License plate number from `delivery.plateNumber`.
  final String? plateNumber;

  /// Vehicle color (Arabic or English) from `delivery.vehicleColor`.
  final String? vehicleColor;

  /// Human-readable vehicle description, e.g. "سيبيسب - car | 555555"
  String get vehicleDescription {
    final parts = <String>[];
    if (vehicleColor != null && vehicleColor!.isNotEmpty) {
      parts.add(vehicleColor!);
    }
    if (vehicleType != null && vehicleType!.isNotEmpty) {
      parts.add(vehicleType!);
    }
    final base = parts.join(' - ');
    if (plateNumber != null && plateNumber!.isNotEmpty) {
      return base.isNotEmpty ? '$base | $plateNumber' : plateNumber!;
    }
    return base;
  }

  @override
  List<Object?> get props =>
      [name, phone, vehicleType, plateNumber, vehicleColor];
}
