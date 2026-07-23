import 'package:equatable/equatable.dart';

import 'order_item.dart';

/// User order summary returned by GET /orders.
class Order extends Equatable {
  const Order({
    required this.id,
    required this.status,
    required this.total,
    required this.deliveryFee,
    required this.createdAt,
    required this.items,
  });

  final int id;
  final String status;
  final double total;
  final double deliveryFee;
  final DateTime? createdAt;
  final List<OrderItem> items;

  @override
  List<Object?> get props => [id, status, total, deliveryFee, createdAt, items];
}
