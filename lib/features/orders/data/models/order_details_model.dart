import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/order_details.dart';
import 'billing_model.dart';
import 'location_model.dart';
import 'order_item_model.dart';
import 'restaurant_model.dart';

class OrderDetailsModel extends OrderDetails {
  const OrderDetailsModel({
    required super.orderId,
    required super.status,
    required super.billing,
    required super.restaurant,
    required super.preparationTime,
    required super.location,
    required super.items,
  });

  factory OrderDetailsModel.fromJson(Map<String, dynamic> json) {
    final billingJson = json['billing'];
    final restaurantJson = json['restaurant'];
    final locationJson = json['location'];
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

    return OrderDetailsModel(
      orderId: JsonParsers.toInt(json['orderId'] ?? json['id']),
      status: json['status']?.toString() ?? '',
      billing: billingJson is Map
          ? BillingModel.fromJson(Map<String, dynamic>.from(billingJson))
          : const BillingModel(
              subtotal: 0,
              deliveryFee: 0,
              serviceFee: 0,
              totalAmount: 0,
            ),
      restaurant: restaurantJson is Map
          ? RestaurantModel.fromJson(Map<String, dynamic>.from(restaurantJson))
          : const RestaurantModel(id: 0, nameAr: '', nameEn: '', phone: ''),
      preparationTime: JsonParsers.toInt(json['preparationTime']),
      location: locationJson is Map
          ? LocationModel.fromJson(Map<String, dynamic>.from(locationJson))
          : const LocationModel(lat: 0, lng: 0),
      items: items,
    );
  }

  Map<String, dynamic> toJson() => {
        'orderId': orderId,
        'status': status,
        'billing': (billing as BillingModel).toJson(),
        'restaurant': (restaurant as RestaurantModel).toJson(),
        'preparationTime': preparationTime,
        'location': (location as LocationModel).toJson(),
        'items': items.map((item) => (item as OrderItemModel).toJson()).toList(),
      };

  OrderDetails toEntity() => OrderDetails(
        orderId: orderId,
        status: status,
        billing: (billing as BillingModel).toEntity(),
        restaurant: (restaurant as RestaurantModel).toEntity(),
        preparationTime: preparationTime,
        location: (location as LocationModel).toEntity(),
        items: items.map((item) => (item as OrderItemModel).toEntity()).toList(),
      );
}
