import 'package:equatable/equatable.dart';

class Payment extends Equatable {
  const Payment({
    required this.amount,
    required this.method,
    required this.status,
  });

  final double amount;
  final String method;
  final String status;

  @override
  List<Object?> get props => [amount, method, status];
}
