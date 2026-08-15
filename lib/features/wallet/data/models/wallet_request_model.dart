import '../../domain/entities/wallet_request.dart';

class WalletRequestModel extends WalletRequest {
  const WalletRequestModel({
    required super.id,
    required super.amount,
    required super.paymentMethod,
    required super.status,
    required super.createdAt,
  });

  factory WalletRequestModel.fromJson(Map<String, dynamic> json) {
    return WalletRequestModel(
      id: json['id'] as int,
      amount: double.parse(json['amount'].toString()),
      paymentMethod: json['payment_method'] as String,
      status: json['status'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount.toString(),
      'payment_method': paymentMethod,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
