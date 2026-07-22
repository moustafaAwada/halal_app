import 'package:equatable/equatable.dart';

class ConfirmOrderResult extends Equatable {
  const ConfirmOrderResult({
    this.message,
    this.orderId,
  });

  final String? message;
  final int? orderId;

  @override
  List<Object?> get props => [message, orderId];
}
