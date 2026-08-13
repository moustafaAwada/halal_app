import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/product_vendor.dart';

class ProductVendorModel extends ProductVendor {
  const ProductVendorModel({
    required super.id,
    required super.nameAr,
    required super.nameEn,
    required super.imageUrl,
    required super.cover,
    required super.avgRating,
  });

  factory ProductVendorModel.fromJson(Map<String, dynamic> json) {
    return ProductVendorModel(
      id: JsonParsers.toInt(json['id']),
      nameAr: json['name_ar']?.toString() ?? json['name']?.toString() ?? '',
      nameEn: json['name_en']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      cover: json['cover']?.toString() ?? '',
      avgRating: JsonParsers.toDouble(json['avgRating']),
    );
  }

  ProductVendor toEntity() => ProductVendor(
        id: id,
        nameAr: nameAr,
        nameEn: nameEn,
        imageUrl: imageUrl,
        cover: cover,
        avgRating: avgRating,
      );
}
