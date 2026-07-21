import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/search_product.dart';
import 'search_product_category_model.dart';

class SearchProductModel extends SearchProduct {
  const SearchProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.image,
    required super.price,
    super.priceBeforeDiscount,
    super.discountPercentage,
    required super.isAvailable,
    required super.averageRating,
    required super.reviewsCount,
    super.category,
  });

  factory SearchProductModel.fromJson(Map<String, dynamic> json) {
    final priceBeforeDiscount = JsonParsers.toDouble(
      json['price_before_discount'],
    );
    final discountPercentage = JsonParsers.toInt(json['discount_percentage']);

    SearchProductCategoryModel? category;
    final categoryJson = json['category'];
    if (categoryJson is Map) {
      category = SearchProductCategoryModel.fromJson(
        Map<String, dynamic>.from(categoryJson),
      );
    }

    return SearchProductModel(
      id: JsonParsers.toInt(json['id']),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      image: json['image'] as String? ?? '',
      price: JsonParsers.toDouble(json['price']),
      priceBeforeDiscount: priceBeforeDiscount > 0 ? priceBeforeDiscount : null,
      discountPercentage: discountPercentage > 0 ? discountPercentage : null,
      isAvailable: JsonParsers.toBool(json['is_available']),
      averageRating: JsonParsers.toDouble(json['average_rating']),
      reviewsCount: JsonParsers.toInt(json['reviews_count']),
      category: category,
    );
  }

  SearchProduct toEntity() => SearchProduct(
        id: id,
        name: name,
        description: description,
        image: image,
        price: price,
        priceBeforeDiscount: priceBeforeDiscount,
        discountPercentage: discountPercentage,
        isAvailable: isAvailable,
        averageRating: averageRating,
        reviewsCount: reviewsCount,
        category: category,
      );
}
