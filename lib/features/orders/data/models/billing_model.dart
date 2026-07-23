import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/billing.dart';

class BillingModel extends Billing {
  const BillingModel({
    required super.subtotal,
    required super.deliveryFee,
    required super.serviceFee,
    required super.totalAmount,
  });

  factory BillingModel.fromJson(Map<String, dynamic> json) {
    return BillingModel(
      subtotal: JsonParsers.toDouble(json['subtotal']),
      deliveryFee: JsonParsers.toDouble(json['deliveryFee']),
      serviceFee: JsonParsers.toDouble(json['serviceFee']),
      totalAmount: JsonParsers.toDouble(json['totalAmount']),
    );
  }

  Map<String, dynamic> toJson() => {
        'subtotal': subtotal,
        'deliveryFee': deliveryFee,
        'serviceFee': serviceFee,
        'totalAmount': totalAmount,
      };

  Billing toEntity() => Billing(
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        serviceFee: serviceFee,
        totalAmount: totalAmount,
      );
}
