import 'package:equatable/equatable.dart';

import 'product_vendor.dart';

class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.rating,
    required this.isFavorite,
    required this.totalSold,
    this.type = 'normal',
    this.reviewCount = 0,
    this.vendor,
  });

  final int id;
  final String name;
  final double price;
  final String image;
  final double rating;
  final bool isFavorite;
  final int totalSold;
  final String type;
  final int reviewCount;
  final ProductVendor? vendor;

  bool get isOffer => type == 'offer';

  @override
  List<Object?> get props => [
        id,
        name,
        price,
        image,
        rating,
        isFavorite,
        totalSold,
        type,
        reviewCount,
        vendor,
      ];
}
