import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  const Customer({
    required this.id,
    required this.phone,
    required this.city,
    required this.walletBalance,
  });

  final int id;
  final String phone;
  final String city;
  final double walletBalance;

  @override
  List<Object?> get props => [id, phone, city, walletBalance];
}
