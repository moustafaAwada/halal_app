import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/cart_item.dart';
import 'cart_addon_model.dart';
import 'cart_menu_model.dart';
import 'cart_size_model.dart';

class CartItemModel extends CartItem {
  const CartItemModel({
    required super.id,
    required super.quantity,
    required super.menu,
    super.note,
    super.size,
    super.addons = const [],
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final menuJson = json['menu'] ?? json['product'];
    final menu = menuJson is Map
        ? CartMenuModel.fromJson(Map<String, dynamic>.from(menuJson))
        : const CartMenuModel(
            id: 0,
            name: '',
            description: '',
            price: 0,
            image: '',
          );

    final sizeJson = json['size'];
    final size = sizeJson is Map
        ? CartSizeModel.fromJson(Map<String, dynamic>.from(sizeJson))
        : null;

    final addonsJson = json['addons'];
    final addons = addonsJson is List
        ? addonsJson
            .whereType<Map>()
            .map(
              (item) => CartAddonModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList()
        : <CartAddonModel>[];

    return CartItemModel(
      id: JsonParsers.toInt(json['id']),
      quantity: JsonParsers.toInt(json['quantity']),
      note: json['note']?.toString(),
      menu: menu,
      size: size,
      addons: addons,
    );
  }

  CartItem toEntity() => CartItem(
        id: id,
        quantity: quantity,
        note: note,
        menu: (menu as CartMenuModel).toEntity(),
        size: size != null ? (size as CartSizeModel).toEntity() : null,
        addons: addons
            .map((addon) => (addon as CartAddonModel).toEntity())
            .toList(),
      );
}
