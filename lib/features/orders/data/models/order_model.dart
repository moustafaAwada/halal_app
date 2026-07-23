import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/order.dart';
import 'order_item_model.dart';

class OrderModel extends Order {
  const OrderModel({
    required super.id,
    required super.status,
    required super.total,
    required super.deliveryFee,
    required super.createdAt,
    required super.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'];
    final items = <OrderItemModel>[];

    if (itemsJson is List) {
      for (final item in itemsJson) {
        if (item is Map) {
          items.add(
            OrderItemModel.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return OrderModel(
      id: JsonParsers.toInt(json['id']),
      status: json['status']?.toString() ?? '',
      total: JsonParsers.toDouble(json['total']),
      deliveryFee: JsonParsers.toDouble(json['deliveryFee']),
      createdAt: _parseDate(json['createdAt']),
      items: items,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status,
        'total': total,
        'deliveryFee': deliveryFee,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        'items': items.map((item) => (item as OrderItemModel).toJson()).toList(),
      };

  static DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  Order toEntity() => Order(
        id: id,
        status: status,
        total: total,
        deliveryFee: deliveryFee,
        createdAt: createdAt,
        items: items.map((item) => (item as OrderItemModel).toEntity()).toList(),
      );
}
