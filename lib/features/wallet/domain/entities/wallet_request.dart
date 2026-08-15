import 'package:equatable/equatable.dart';

class WalletRequest extends Equatable {
  const WalletRequest({
    required this.id,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
  });

  final int id;
  final double amount;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        id,
        amount,
        paymentMethod,
        status,
        createdAt,
      ];
}
