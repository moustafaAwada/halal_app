import '../../domain/entities/complete_trip_result.dart';
import '../../domain/entities/trip.dart';
import '../../domain/entities/trip_status.dart';
import 'payment_model.dart';
import 'trip_model.dart';

class CompleteTripResultModel extends CompleteTripResult {
  const CompleteTripResultModel({
    required super.trip,
    required super.payment,
    super.message,
  });

  factory CompleteTripResultModel.fromJson(
    Map<String, dynamic> json, {
    String? message,
  }) {
    final tripJson = json['trip'];
    final paymentJson = json['payment'];

    final Trip trip = tripJson is Map
        ? TripModel.fromJson(Map<String, dynamic>.from(tripJson)).toEntity()
        : const Trip(id: 0, status: TripStatus.completed);

    final payment = paymentJson is Map
        ? PaymentModel.fromJson(Map<String, dynamic>.from(paymentJson))
            .toEntity()
        : const PaymentModel(amount: 0, method: '', status: '').toEntity();

    return CompleteTripResultModel(
      trip: trip,
      payment: payment,
      message: message,
    );
  }
}
