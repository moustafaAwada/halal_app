import 'package:equatable/equatable.dart';

import 'cart_addon.dart';
import 'cart_menu.dart';
import 'cart_size.dart';

class CartItem extends Equatable {
  const CartItem({
    required this.id,
    required this.quantity,
    required this.menu,
    this.note,
    this.size,
    this.addons = const [],
  });

  final int id;
  final int quantity;
  final String? note;
  final CartMenu menu;
  final CartSize? size;
  final List<CartAddon> addons;

  double get unitPrice {
    final sizePrice = size?.price ?? 0;
    final addonsPrice = addons.fold<double>(0, (sum, addon) => sum + addon.price);
    return menu.price + sizePrice + addonsPrice;
  }

  double get lineTotal => unitPrice * quantity;

  CartItem mergeWith(CartItem updated) {
    return CartItem(
      id: updated.id,
      quantity: updated.quantity,
      note: updated.note ?? note,
      menu: updated.menu.isComplete ? updated.menu : menu,
      size: updated.size ?? size,
      addons: updated.addons.isNotEmpty ? updated.addons : addons,
    );
  }

  @override
  List<Object?> get props => [id, quantity, note, menu, size, addons];
}
