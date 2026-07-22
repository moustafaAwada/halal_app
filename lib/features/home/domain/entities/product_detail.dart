import 'package:equatable/equatable.dart';

class ProductDetail extends Equatable {
  const ProductDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.price,
    required this.priceBeforeDiscount,
    required this.discountPercentage,
    required this.type,
    this.vendorId,
    this.categoryId,
  });

  final int id;
  final String name;
  final String description;
  final String image;
  final double price;
  final double? priceBeforeDiscount;
  final int discountPercentage;
  final String type;
  final int? vendorId;
  final int? categoryId;

  bool get isOffer => type == 'offer';

  bool get hasDiscount => discountPercentage > 0;

  double? get displayPriceBeforeDiscount {
    if (priceBeforeDiscount != null && priceBeforeDiscount! > price) {
      return priceBeforeDiscount;
    }

    if (discountPercentage > 0 && discountPercentage < 100) {
      return price / (1 - discountPercentage / 100.0);
    }

    return null;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        image,
        price,
        priceBeforeDiscount,
        discountPercentage,
        type,
        vendorId,
        categoryId,
      ];
}
