import 'package:equatable/equatable.dart';

import 'order_addon.dart';

class OrderItem extends Equatable {
  const OrderItem({
    required this.id,
    required this.quantity,
    required this.price,
    required this.total,
    this.menuName,
    this.menuId,
    this.menuImage,
    this.deliveryTime,
    this.sizeName,
    this.addons = const [],
  });

  final int id;
  final int quantity;
  final double price;
  final double total;
  final String? menuName;
  final int? menuId;
  final String? menuImage;
  final int? deliveryTime;
  final String? sizeName;
  final List<OrderAddon> addons;

  @override
  List<Object?> get props => [
        id,
        quantity,
        price,
        total,
        menuName,
        menuId,
        menuImage,
        deliveryTime,
        sizeName,
        addons,
      ];
}
