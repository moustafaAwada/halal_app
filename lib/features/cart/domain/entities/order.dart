import 'package:equatable/equatable.dart';

class Order extends Equatable {
  const Order({
    required this.id,
    required this.status,
    required this.totalPrice,
    this.deliveryFee,
    this.deliveryTime,
    this.paymentMethod,
    this.latitude,
    this.longitude,
    this.vendorId,
    this.vendorName,
    this.profitValue,
    this.deliveryStatus,
  });

  final int id;
  final String status;
  final double totalPrice;
  final double? deliveryFee;
  final String? deliveryTime;
  final String? paymentMethod;
  final double? latitude;
  final double? longitude;
  final int? vendorId;
  final String? vendorName;
  final double? profitValue;
  final String? deliveryStatus;

  @override
  List<Object?> get props => [
        id,
        status,
        totalPrice,
        deliveryFee,
        deliveryTime,
        paymentMethod,
        latitude,
        longitude,
        vendorId,
        vendorName,
        profitValue,
        deliveryStatus,
      ];
}
