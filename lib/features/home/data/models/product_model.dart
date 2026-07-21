import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.price,
    required super.image,
    required super.rating,
    required super.isFavorite,
    required super.totalSold,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: JsonParsers.toInt(json['id']),
      name: json['name'] as String? ?? '',
      price: JsonParsers.toDouble(json['price']),
      image: json['image'] as String? ?? '',
      rating: JsonParsers.toDouble(json['rating']),
      isFavorite: JsonParsers.toBool(json['isFavorite']),
      totalSold: JsonParsers.toInt(json['total_sold']),
    );
  }

  Product toEntity() => Product(
        id: id,
        name: name,
        price: price,
        image: image,
        rating: rating,
        isFavorite: isFavorite,
        totalSold: totalSold,
      );
}
