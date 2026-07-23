import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/location.dart';

class LocationModel extends Location {
  const LocationModel({
    required super.lat,
    required super.lng,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      lat: JsonParsers.toDouble(json['lat']),
      lng: JsonParsers.toDouble(json['lng']),
    );
  }

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
      };

  Location toEntity() => Location(lat: lat, lng: lng);
}
