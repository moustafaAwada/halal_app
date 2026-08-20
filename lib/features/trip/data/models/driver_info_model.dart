import '../../domain/entities/driver_info.dart';

/// Data model that parses the `delivery` object from the trip API response.
///
/// Example JSON:
/// ```json
/// {
///   "phone": "01098583817",
///   "vehicleType": "car",
///   "plateNumber": "555555",
///   "vehicleColor": "سيبيسب",
///   "user": { "name": "Ahmed Sabry Mahmoud" }
/// }
/// ```
class DriverInfoModel extends DriverInfo {
  const DriverInfoModel({
    required super.name,
    super.phone,
    super.vehicleType,
    super.plateNumber,
    super.vehicleColor,
  });

  factory DriverInfoModel.fromJson(Map<String, dynamic> json) {
    // Extract driver name from the nested user object.
    final userMap = json['user'];
    final driverName = (userMap is Map ? userMap['name']?.toString() : null) ??
        json['name']?.toString() ??
        '';

    return DriverInfoModel(
      name: driverName,
      phone: json['phone']?.toString(),
      vehicleType: json['vehicleType']?.toString() ??
          json['vehicle_type']?.toString(),
      plateNumber: json['plateNumber']?.toString() ??
          json['plate_number']?.toString(),
      vehicleColor: json['vehicleColor']?.toString() ??
          json['vehicle_color']?.toString(),
    );
  }

  DriverInfo toEntity() => DriverInfo(
        name: name,
        phone: phone,
        vehicleType: vehicleType,
        plateNumber: plateNumber,
        vehicleColor: vehicleColor,
      );
}
