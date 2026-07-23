import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/order_addon.dart';

class OrderAddonModel extends OrderAddon {
  const OrderAddonModel({
    required super.id,
    required super.name,
    required super.price,
  });

  factory OrderAddonModel.fromJson(Map<String, dynamic> json) {
    return OrderAddonModel(
      id: JsonParsers.toInt(json['id']),
      name: json['name']?.toString() ?? '',
      price: JsonParsers.toDouble(json['price']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
      };

  OrderAddon toEntity() => OrderAddon(id: id, name: name, price: price);
}
