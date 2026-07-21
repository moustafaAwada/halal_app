import 'package:equatable/equatable.dart';

class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.rating,
    required this.isFavorite,
    required this.totalSold,
  });

  final int id;
  final String name;
  final double price;
  final String image;
  final double rating;
  final bool isFavorite;
  final int totalSold;

  @override
  List<Object?> get props => [id, name, price, image, rating, isFavorite, totalSold];
}
