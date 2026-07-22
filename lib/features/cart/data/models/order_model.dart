import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/order.dart';

class OrderModel extends Order {
  const OrderModel({
    required super.id,
    required super.status,
    required super.totalPrice,
    super.deliveryFee,
    super.deliveryTime,
    super.paymentMethod,
    super.latitude,
    super.longitude,
    super.vendorId,
    super.vendorName,
    super.profitValue,
    super.deliveryStatus,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final vendor = json['vendor'];
    int? vendorId;
    String? vendorName;

    if (vendor is Map) {
      vendorId = JsonParsers.toInt(vendor['id']);
      vendorName = vendor['name']?.toString();
    }

    return OrderModel(
      id: JsonParsers.toInt(json['id']),
      status: json['status']?.toString() ?? '',
      totalPrice: JsonParsers.toDouble(
        json['total'] ?? json['total_price'] ?? json['totalPrice'],
      ),
      deliveryFee: _optionalDouble(json['delivery_fee'] ?? json['deliveryFee']),
      deliveryTime: json['delivery_time']?.toString() ??
          json['deliveryTime']?.toString(),
      paymentMethod: json['payment_method']?.toString() ??
          json['paymentMethod']?.toString(),
      latitude: _optionalDouble(json['latitude']),
      longitude: _optionalDouble(json['longitude']),
      vendorId: vendorId ?? JsonParsers.toInt(json['vendor_id']),
      vendorName: vendorName,
      profitValue: _optionalDouble(json['profit_value']),
      deliveryStatus: json['delivery_status']?.toString(),
    );
  }

  static double? _optionalDouble(dynamic value) {
    if (value == null) return null;
    return JsonParsers.toDouble(value);
  }

  Order toEntity() => Order(
        id: id,
        status: status,
        totalPrice: totalPrice,
        deliveryFee: deliveryFee,
        deliveryTime: deliveryTime,
        paymentMethod: paymentMethod,
        latitude: latitude,
        longitude: longitude,
        vendorId: vendorId,
        vendorName: vendorName,
        profitValue: profitValue,
        deliveryStatus: deliveryStatus,
      );
}
