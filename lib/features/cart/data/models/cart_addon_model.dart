import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/cart_addon.dart';

class CartAddonModel extends CartAddon {
  const CartAddonModel({
    required super.id,
    required super.name,
    required super.price,
  });

  factory CartAddonModel.fromJson(Map<String, dynamic> json) {
    final nestedAddon = json['addon'];
    if (nestedAddon is Map) {
      final addon = Map<String, dynamic>.from(nestedAddon);
      return CartAddonModel(
        id: JsonParsers.toInt(addon['id']),
        name: addon['name']?.toString() ?? '',
        price: JsonParsers.toDouble(addon['price']),
      );
    }

    return CartAddonModel(
      id: JsonParsers.toInt(json['id']),
      name: json['name']?.toString() ?? '',
      price: JsonParsers.toDouble(json['price']),
    );
  }

  CartAddon toEntity() => CartAddon(id: id, name: name, price: price);
}
