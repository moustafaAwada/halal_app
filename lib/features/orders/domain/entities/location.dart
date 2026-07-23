import 'package:equatable/equatable.dart';

class Location extends Equatable {
  const Location({
    required this.lat,
    required this.lng,
  });

  final double lat;
  final double lng;

  @override
  List<Object?> get props => [lat, lng];
}
