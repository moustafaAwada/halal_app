import 'package:equatable/equatable.dart';

import 'favorite_vendor.dart';

class FavoriteMenu extends Equatable {
  const FavoriteMenu({
    required this.id,
    required this.name,
    required this.description,
    required this.originalPrice,
    required this.price,
    this.priceBeforeDiscount,
    required this.image,
    this.vendor,
  });

  final int id;
  final String name;
  final String description;
  final double originalPrice;
  final double price;
  final double? priceBeforeDiscount;
  final String image;
  final FavoriteVendor? vendor;

  bool get hasDiscount =>
      priceBeforeDiscount != null && priceBeforeDiscount! > price;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        originalPrice,
        price,
        priceBeforeDiscount,
        image,
        vendor,
      ];
}
