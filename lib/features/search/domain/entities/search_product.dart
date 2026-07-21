import 'package:equatable/equatable.dart';

import 'search_product_category.dart';

class SearchProduct extends Equatable {
  const SearchProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.price,
    this.priceBeforeDiscount,
    this.discountPercentage,
    required this.isAvailable,
    required this.averageRating,
    required this.reviewsCount,
    this.category,
  });

  final int id;
  final String name;
  final String description;
  final String image;
  final double price;
  final double? priceBeforeDiscount;
  final int? discountPercentage;
  final bool isAvailable;
  final double averageRating;
  final int reviewsCount;
  final SearchProductCategory? category;

  bool get hasDiscount =>
      priceBeforeDiscount != null &&
      priceBeforeDiscount! > price &&
      (discountPercentage ?? 0) > 0;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        image,
        price,
        priceBeforeDiscount,
        discountPercentage,
        isAvailable,
        averageRating,
        reviewsCount,
        category,
      ];
}
