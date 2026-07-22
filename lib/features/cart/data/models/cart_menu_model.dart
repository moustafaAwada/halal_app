import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/cart_menu.dart';

class CartMenuModel extends CartMenu {
  const CartMenuModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.image,
    super.vendorId,
    super.vendorName,
  });

  factory CartMenuModel.fromJson(Map<String, dynamic> json) {
    final vendor = json['vendor'];
    int? vendorId;
    String? vendorName;

    if (vendor is Map) {
      vendorId = JsonParsers.toInt(vendor['id']);
      vendorName = vendor['name']?.toString();
    }

    return CartMenuModel(
      id: JsonParsers.toInt(json['id']),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: _parsePrice(json),
      image: json['image']?.toString() ??
          json['image_url']?.toString() ??
          '',
      vendorId: vendorId ?? JsonParsers.toInt(json['vendor_id']),
      vendorName: vendorName,
    );
  }

  static double _parsePrice(Map<String, dynamic> json) {
    final price = JsonParsers.toDouble(json['price']);
    if (price > 0) return price;

    final originalPrice = JsonParsers.toDouble(json['original_price']);
    if (originalPrice > 0) return originalPrice;

    return JsonParsers.toDouble(json['final_price']);
  }

  CartMenu toEntity() => CartMenu(
        id: id,
        name: name,
        description: description,
        price: price,
        image: image,
        vendorId: vendorId,
        vendorName: vendorName,
      );
}
