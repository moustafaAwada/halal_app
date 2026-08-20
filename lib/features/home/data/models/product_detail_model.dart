import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/product_detail.dart';
import 'addon_model.dart';
import 'product_vendor_model.dart';
import 'size_model.dart';

class ProductDetailModel extends ProductDetail {
  const ProductDetailModel({
    required super.id,
    required super.name,
    required super.description,
    required super.image,
    required super.price,
    required super.priceBeforeDiscount,
    required super.discountPercentage,
    required super.type,
    super.vendorId,
    super.categoryId,
    super.rating,
    super.reviewCount,
    super.totalSold,
    super.isFavorite,
    super.vendor,
    super.sizes,
    super.addons,
  });

  factory ProductDetailModel.fromJson(Map<String, dynamic> json) {
    final price = JsonParsers.toDouble(json['price']);
    final discount = JsonParsers.toDouble(
      json['discount_percentage'] ?? json['discount'],
    ).round();
    final priceBeforeDiscount =
        _resolvePriceBeforeDiscount(json, price, discount);

    ProductVendorModel? vendor;
    final vendorJson = json['vendor'];
    if (vendorJson is Map) {
      vendor = ProductVendorModel.fromJson(
        Map<String, dynamic>.from(vendorJson),
      );
    }

    // Safely parse the sizes list; defaults to empty if missing or malformed.
    final sizesJson = json['sizes'];
    final sizes = sizesJson is List
        ? sizesJson
            .whereType<Map>()
            .map((e) => SizeModel.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <SizeModel>[];

    // Safely parse the addons list; defaults to empty if missing or malformed.
    final addonsJson = json['addons'];
    final addons = addonsJson is List
        ? addonsJson
            .whereType<Map>()
            .map((e) => AddonModel.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <AddonModel>[];

    return ProductDetailModel(
      id: JsonParsers.toInt(json['id']),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      image: json['image'] as String? ?? '',
      price: price,
      priceBeforeDiscount: priceBeforeDiscount,
      discountPercentage: discount,
      type: json['type'] as String? ?? 'normal',
      vendorId: json['vendor_id'] == null && vendor == null
          ? null
          : JsonParsers.toInt(json['vendor_id'] ?? vendor?.id),
      categoryId: json['category_id'] == null
          ? null
          : JsonParsers.toInt(json['category_id']),
      rating: JsonParsers.toDouble(json['rating'] ?? json['average_rating']),
      reviewCount: JsonParsers.toInt(
        json['reviewCount'] ?? json['reviews_count'],
      ),
      totalSold: JsonParsers.toInt(json['total_sold']),
      isFavorite: JsonParsers.toBool(json['isFavorite']),
      vendor: vendor,
      sizes: sizes,
      addons: addons,
    );
  }

  static double? _resolvePriceBeforeDiscount(
    Map<String, dynamic> json,
    double price,
    int discount,
  ) {
    final explicit = JsonParsers.toDouble(json['price_before_discount']);
    if (explicit > price) return explicit;
    if (discount > 0 && discount < 100) {
      return price / (1 - discount / 100.0);
    }
    return null;
  }

  ProductDetail toEntity() => ProductDetail(
        id: id,
        name: name,
        description: description,
        image: image,
        price: price,
        priceBeforeDiscount: priceBeforeDiscount,
        discountPercentage: discountPercentage,
        type: type,
        vendorId: vendorId,
        categoryId: categoryId,
        rating: rating,
        reviewCount: reviewCount,
        totalSold: totalSold,
        isFavorite: isFavorite,
        vendor: vendor,
        sizes: sizes,
        addons: addons,
      );
}
