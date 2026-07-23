import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/order_item.dart';
import 'order_addon_model.dart';

class OrderItemModel extends OrderItem {
  const OrderItemModel({
    required super.id,
    required super.quantity,
    required super.price,
    required super.total,
    super.menuName,
    super.menuId,
    super.menuImage,
    super.deliveryTime,
    super.sizeName,
    super.addons = const [],
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final menuJson = json['Menu'] ?? json['menu'];
    final sizeJson = json['size'];
    final addonsJson = json['addons'];

    String? menuName;
    int? menuId;
    String? menuImage;
    int? deliveryTime;

    if (menuJson is Map) {
      final menu = Map<String, dynamic>.from(menuJson);
      menuName = menu['name']?.toString();
      menuId = JsonParsers.toInt(menu['id']);
      menuImage = menu['image']?.toString();
      deliveryTime = JsonParsers.toInt(menu['deliveryTime']);
    }

    final addons = <OrderAddonModel>[];
    if (addonsJson is List) {
      for (final addon in addonsJson) {
        if (addon is Map) {
          addons.add(
            OrderAddonModel.fromJson(Map<String, dynamic>.from(addon)),
          );
        }
      }
    }

    return OrderItemModel(
      id: JsonParsers.toInt(json['id']),
      quantity: JsonParsers.toInt(json['quantity']),
      price: JsonParsers.toDouble(json['price']),
      total: JsonParsers.toDouble(json['total']),
      menuName: json['menu_name']?.toString() ?? menuName,
      menuId: menuId,
      menuImage: menuImage,
      deliveryTime: deliveryTime,
      sizeName: sizeJson is Map ? sizeJson['name']?.toString() : null,
      addons: addons,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'quantity': quantity,
        'price': price,
        'total': total,
        if (menuName != null) 'menu_name': menuName,
        if (sizeName != null) 'size': {'name': sizeName},
        'addons': addons
            .map((addon) => (addon as OrderAddonModel).toJson())
            .toList(),
      };

  OrderItem toEntity() => OrderItem(
        id: id,
        quantity: quantity,
        price: price,
        total: total,
        menuName: menuName,
        menuId: menuId,
        menuImage: menuImage,
        deliveryTime: deliveryTime,
        sizeName: sizeName,
        addons: addons
            .map((addon) => (addon as OrderAddonModel).toEntity())
            .toList(),
      );
}
