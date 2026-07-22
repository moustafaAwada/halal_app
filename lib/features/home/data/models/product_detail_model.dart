import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/product_detail.dart';

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
  });

  factory ProductDetailModel.fromJson(Map<String, dynamic> json) {
    final price = JsonParsers.toDouble(json['price']);
    final discount = JsonParsers.toDouble(
      json['discount_percentage'] ?? json['discount'],
    ).round();
    final priceBeforeDiscount = _resolvePriceBeforeDiscount(json, price, discount);

    return ProductDetailModel(
      id: JsonParsers.toInt(json['id']),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      image: json['image'] as String? ?? '',
      price: price,
      priceBeforeDiscount: priceBeforeDiscount,
      discountPercentage: discount,
      type: json['type'] as String? ?? 'normal',
      vendorId: json['vendor_id'] == null
          ? null
          : JsonParsers.toInt(json['vendor_id']),
      categoryId: json['category_id'] == null
          ? null
          : JsonParsers.toInt(json['category_id']),
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
      );
}
