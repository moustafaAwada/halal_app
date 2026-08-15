import 'package:equatable/equatable.dart';

class RechargeResponse extends Equatable {
  const RechargeResponse({
    required this.success,
    required this.message,
  });

  final bool success;
  final String message;

  @override
  List<Object?> get props => [success, message];
}
