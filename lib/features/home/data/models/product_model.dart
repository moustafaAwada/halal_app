import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/product.dart';
import 'product_vendor_model.dart';

class ProductModel extends Product {
  const ProductModel({
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
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    ProductVendorModel? vendor;
    final vendorJson = json['vendor'];
    if (vendorJson is Map) {
      vendor = ProductVendorModel.fromJson(
        Map<String, dynamic>.from(vendorJson),
      );
    }

    return ProductModel(
      id: JsonParsers.toInt(json['id']),
      name: json['name'] as String? ?? '',
      price: JsonParsers.toDouble(json['price']),
      image: json['image'] as String? ?? '',
      rating: JsonParsers.toDouble(json['rating'] ?? json['average_rating']),
      isFavorite: JsonParsers.toBool(json['isFavorite']),
      totalSold: JsonParsers.toInt(json['total_sold']),
      type: json['type'] as String? ?? 'normal',
      reviewCount: JsonParsers.toInt(
        json['reviewCount'] ?? json['reviews_count'],
      ),
      vendor: vendor,
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
        type: type,
        reviewCount: reviewCount,
        vendor: vendor,
      );
}
