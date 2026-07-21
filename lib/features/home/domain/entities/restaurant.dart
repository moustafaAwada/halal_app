import 'package:equatable/equatable.dart';

class Restaurant extends Equatable {
  const Restaurant({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.avgRating,
    required this.buyersCount,
    required this.menusCount,
  });

  final int id;
  final String name;
  final String imageUrl;
  final double avgRating;
  final int buyersCount;
  final int menusCount;

  @override
  List<Object?> get props => [id, name, imageUrl, avgRating, buyersCount, menusCount];
}
