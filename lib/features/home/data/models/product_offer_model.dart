import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/product_offer.dart';
import 'product_model.dart';

class ProductOfferModel extends ProductOffer {
  const ProductOfferModel({
    required super.id,
    required super.name,
    required super.price,
    required super.image,
    required super.rating,
    required super.isFavorite,
    required super.totalSold,
    super.type,
    super.reviewCount,
    super.vendor,
    required super.oldPrice,
    required super.discount,
  });

  factory ProductOfferModel.fromJson(Map<String, dynamic> json) {
    final product = ProductModel.fromJson(json);
    final discount = JsonParsers.toDouble(
      json['discount_percentage'] ?? json['discount'],
    ).round();
    final oldPrice = _resolveOldPrice(json, product.price, discount);

    return ProductOfferModel(
      id: product.id,
      name: product.name,
      price: product.price,
      image: product.image,
      rating: product.rating,
      isFavorite: product.isFavorite,
      totalSold: product.totalSold,
      type: product.type,
      reviewCount: product.reviewCount,
      vendor: product.vendor,
      oldPrice: oldPrice,
      discount: discount,
    );
  }

  static double _resolveOldPrice(
    Map<String, dynamic> json,
    double price,
    int discount,
  ) {
    final explicitOldPrice = JsonParsers.toDouble(
      json['old_price'] ?? json['price_before_discount'],
    );
    if (explicitOldPrice > price) return explicitOldPrice;
    if (discount > 0 && discount < 100) {
      return price / (1 - discount / 100.0);
    }
    return price;
  }

  ProductOffer toEntity() => ProductOffer(
        id: id,
        name: name,
        price: price,
        image: image,
        rating: rating,
        isFavorite: isFavorite,
        totalSold: totalSold,
        type: type,
        reviewCount: reviewCount,
        vendor: vendor,
        oldPrice: oldPrice,
        discount: discount,
      );
}
