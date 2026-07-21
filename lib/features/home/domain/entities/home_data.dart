import 'package:equatable/equatable.dart';

import 'product.dart';
import 'product_offer.dart';
import 'restaurant.dart';
import 'review.dart';

class HomeData extends Equatable {
  const HomeData({
    required this.topProducts,
    required this.topProductsOffer,
    required this.reviews,
    required this.restaurants,
  });

  final List<Product> topProducts;
  final List<ProductOffer> topProductsOffer;
  final List<Review> reviews;
  final List<Restaurant> restaurants;

  @override
  List<Object?> get props => [topProducts, topProductsOffer, reviews, restaurants];
}
