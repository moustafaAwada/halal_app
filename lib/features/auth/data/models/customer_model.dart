import '../../domain/entities/customer.dart';

class CustomerModel extends Customer {
  const CustomerModel({
    required super.id,
    required super.phone,
    required super.city,
    required super.walletBalance,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      phone: json['phone'] as String? ?? '',
      city: json['city'] as String? ?? '',
      walletBalance: (json['wallet_balance'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'phone': phone,
        'city': city,
        'wallet_balance': walletBalance,
      };

  Customer toEntity() => Customer(
        id: id,
        phone: phone,
        city: city,
        walletBalance: walletBalance,
      );
}
