import 'package:equatable/equatable.dart';

class Billing extends Equatable {
  const Billing({
    required this.subtotal,
    required this.deliveryFee,
    required this.serviceFee,
    required this.totalAmount,
  });

  final double subtotal;
  final double deliveryFee;
  final double serviceFee;
  final double totalAmount;

  @override
  List<Object?> get props => [subtotal, deliveryFee, serviceFee, totalAmount];
}
