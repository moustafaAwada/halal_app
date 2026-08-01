import '../../domain/entities/payment.dart';

class PaymentModel extends Payment {
  const PaymentModel({
    required super.amount,
    required super.method,
    required super.status,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      amount: _asDouble(json['amount']),
      method: json['method']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'method': method,
      'status': status,
    };
  }

  Payment toEntity() => Payment(
        amount: amount,
        method: method,
        status: status,
      );

  static double _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}
