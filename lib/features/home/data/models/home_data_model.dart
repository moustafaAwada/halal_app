import '../../domain/entities/home_data.dart';
import 'product_model.dart';
import 'product_offer_model.dart';
import 'restaurant_model.dart';
import 'review_model.dart';

class HomeDataModel extends HomeData {
  const HomeDataModel({
    required super.topProducts,
    required super.topProductsOffer,
    required super.reviews,
    required super.restaurants,
  });

  factory HomeDataModel.fromJson(Map<String, dynamic> json) {
    return HomeDataModel(
      topProducts: _parseList(json['topProducts'], ProductModel.fromJson),
      topProductsOffer:
          _parseList(json['topProductsOffer'], ProductOfferModel.fromJson),
      reviews: _parseList(json['reviews'], ReviewModel.fromJson),
      restaurants: _parseList(json['restaurants'], RestaurantModel.fromJson),
    );
  }

  static List<T> _parseList<T>(
    dynamic value,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (value is! List) return [];
    return value
        .whereType<Map>()
        .map((item) => fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  HomeData toEntity() => HomeData(
        topProducts: topProducts.map((e) => (e as ProductModel).toEntity()).toList(),
        topProductsOffer:
            topProductsOffer.map((e) => (e as ProductOfferModel).toEntity()).toList(),
        reviews: reviews.map((e) => (e as ReviewModel).toEntity()).toList(),
        restaurants:
            restaurants.map((e) => (e as RestaurantModel).toEntity()).toList(),
      );
}
