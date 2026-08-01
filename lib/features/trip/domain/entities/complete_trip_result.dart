import 'package:equatable/equatable.dart';

import 'payment.dart';
import 'trip.dart';

class CompleteTripResult extends Equatable {
  const CompleteTripResult({
    required this.trip,
    required this.payment,
    this.message,
  });

  final Trip trip;
  final Payment payment;
  final String? message;

  @override
  List<Object?> get props => [trip, payment, message];
}
