import 'package:equatable/equatable.dart';

import 'billing.dart';
import 'location.dart';
import 'order_item.dart';
import 'restaurant.dart';

/// Full order details returned by GET /order-details/{id}.
class OrderDetails extends Equatable {
  const OrderDetails({
    required this.orderId,
    required this.status,
    required this.billing,
    required this.restaurant,
    required this.preparationTime,
    required this.location,
    required this.items,
  });

  final int orderId;
  final String status;
  final Billing billing;
  final Restaurant restaurant;
  final int preparationTime;
  final Location location;
  final List<OrderItem> items;

  @override
  List<Object?> get props => [
        orderId,
        status,
        billing,
        restaurant,
        preparationTime,
        location,
        items,
      ];
}
