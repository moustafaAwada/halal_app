import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/favorite_menu.dart';
import 'favorite_vendor_model.dart';

class FavoriteMenuModel extends FavoriteMenu {
  const FavoriteMenuModel({
    required super.id,
    required super.name,
    required super.description,
    required super.originalPrice,
    required super.price,
    super.priceBeforeDiscount,
    required super.image,
    super.vendor,
  });

  factory FavoriteMenuModel.fromJson(Map<String, dynamic> json) {
    final priceBeforeDiscount = JsonParsers.toDouble(
      json['price_before_discount'],
    );

    FavoriteVendorModel? vendor;
    final vendorJson = json['vendor'];
    if (vendorJson is Map) {
      vendor = FavoriteVendorModel.fromJson(
        Map<String, dynamic>.from(vendorJson),
      );
    }

    return FavoriteMenuModel(
      id: JsonParsers.toInt(json['id']),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      originalPrice: JsonParsers.toDouble(json['original_price']),
      price: JsonParsers.toDouble(json['price']),
      priceBeforeDiscount: priceBeforeDiscount > 0 ? priceBeforeDiscount : null,
      image: json['image'] as String? ?? '',
      vendor: vendor,
    );
  }

  FavoriteMenu toEntity() => FavoriteMenu(
        id: id,
        name: name,
        description: description,
        originalPrice: originalPrice,
        price: price,
        priceBeforeDiscount: priceBeforeDiscount,
        image: image,
        vendor: vendor,
      );
}
