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
    required super.oldPrice,
    required super.discount,
  });

  factory ProductOfferModel.fromJson(Map<String, dynamic> json) {
    final product = ProductModel.fromJson(json);
    final oldPrice = JsonParsers.toDouble(json['old_price']);
    return ProductOfferModel(
      id: product.id,
      name: product.name,
      price: product.price,
      image: product.image,
      rating: product.rating,
      isFavorite: product.isFavorite,
      totalSold: product.totalSold,
      oldPrice: oldPrice > 0 ? oldPrice : product.price,
      discount: JsonParsers.toInt(json['discount']),
    );
  }

  ProductOffer toEntity() => ProductOffer(
        id: id,
        name: name,
        price: price,
        image: image,
        rating: rating,
        isFavorite: isFavorite,
        totalSold: totalSold,
        oldPrice: oldPrice,
        discount: discount,
      );
}
