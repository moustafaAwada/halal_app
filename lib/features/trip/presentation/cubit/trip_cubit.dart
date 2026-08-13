import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/payment.dart';
import '../../domain/entities/trip.dart';
import '../../domain/entities/trip_status.dart';
import '../../domain/entities/trip_tracking.dart';
import '../../domain/usecases/accept_trip.dart';
import '../../domain/usecases/cancel_trip.dart';
import '../../domain/usecases/complete_trip.dart';
import '../../domain/usecases/driver_arrived.dart';
import '../../domain/usecases/rate_trip.dart';
import '../../domain/usecases/request_trip.dart';
import '../../domain/usecases/start_trip.dart';
import '../../domain/usecases/update_tracking.dart';

part 'trip_state.dart';


class TripCubit extends Cubit<TripState> {
  TripCubit({
    required RequestTripUseCase requestTripUseCase,
    required CancelTripUseCase cancelTripUseCase,
    required RateTripUseCase rateTripUseCase,
    required AcceptTripUseCase acceptTripUseCase,
    required DriverArrivedUseCase driverArrivedUseCase,
    required StartTripUseCase startTripUseCase,
    required UpdateTrackingUseCase updateTrackingUseCase,
    required CompleteTripUseCase completeTripUseCase,
  })  : _requestTripUseCase = requestTripUseCase,
        _cancelTripUseCase = cancelTripUseCase,
        _rateTripUseCase = rateTripUseCase,
        _acceptTripUseCase = acceptTripUseCase,
        _driverArrivedUseCase = driverArrivedUseCase,
        _startTripUseCase = startTripUseCase,
        _updateTrackingUseCase = updateTrackingUseCase,
        _completeTripUseCase = completeTripUseCase,
        super(const TripInitial());

  final RequestTripUseCase _requestTripUseCase;
  final CancelTripUseCase _cancelTripUseCase;
  final RateTripUseCase _rateTripUseCase;
  final AcceptTripUseCase _acceptTripUseCase;
  final DriverArrivedUseCase _driverArrivedUseCase;
  final StartTripUseCase _startTripUseCase;
  final UpdateTrackingUseCase _updateTrackingUseCase;
  final CompleteTripUseCase _completeTripUseCase;

  Trip? get currentTrip => switch (state) {
        TripRequested(:final trip) => trip,
        DriverAccepted(:final trip) => trip,
        DriverArrived(:final trip) => trip,
        TripInProgress(:final trip) => trip,
        TripCompleted(:final trip) => trip,
        TripCancelled(:final trip) => trip,
        _ => null,
      };


  Future<void> requestNewTrip(Map<String, dynamic> data) async {
    emit(const TripLoading());

    final result = await _requestTripUseCase(RequestTripParams(data: data));

    result.fold(
      (failure) => emit(TripError(message: failure.message)),
      (trip) {
        final isPrebooking = data['is_prebooking'] == true ||
            data['isPrebooking'] == true ||
            trip.isPrebooking;
        final prebookingTime = _asDateTime(
              data['prebooking_time'] ?? data['prebookingTime'],
            ) ??
            trip.prebookingTime;

        final enriched = trip.copyWith(
          pickupLat: _asDouble(data['pickupLat']) ?? trip.pickupLat,
          pickupLng: _asDouble(data['pickupLng']) ?? trip.pickupLng,
          pickupAddress:
              data['pickupAddress']?.toString() ?? trip.pickupAddress,
          dropoffLat: _asDouble(data['dropoffLat']) ?? trip.dropoffLat,
          dropoffLng: _asDouble(data['dropoffLng']) ?? trip.dropoffLng,
          dropoffAddress:
              data['dropoffAddress']?.toString() ?? trip.dropoffAddress,
          vehicleType: data['vehicleType']?.toString() ?? trip.vehicleType,
          paymentMethod:
              data['paymentMethod']?.toString() ?? trip.paymentMethod,
          fareAmount: _asDouble(data['fareAmount']) ?? trip.fareAmount,
          distanceKm: _asDouble(data['distanceKm']) ?? trip.distanceKm,
          durationMinutes:
              _asInt(data['durationMinutes']) ?? trip.durationMinutes,
          isPrebooking: isPrebooking,
          prebookingTime: prebookingTime,
        );
        emit(
          TripRequested(
            trip: enriched,
            successMessage: isPrebooking
                ? 'تم حجز الرحلة بنجاح'
                : 'تم طلب الرحلة بنجاح',
          ),
        );
      },
    );
  }

  Future<void> cancelCurrentTrip(String reason) async {
    final trip = currentTrip;
    if (trip == null) {
      emit(const TripError(message: 'لا توجد رحلة نشطة للإلغاء'));
      return;
    }

    emit(const TripLoading());

    final result = await _cancelTripUseCase(
      CancelTripParams(
        tripId: trip.id,
        reason: reason,
        cancelledBy: 'customer',
      ),
    );

    result.fold(
      (failure) => emit(TripError(message: failure.message)),
      (message) => emit(
        TripCancelled(
          trip: trip.copyWith(status: TripStatus.cancelledByCustomer),
          successMessage: message.isNotEmpty ? message : 'تم إلغاء الرحلة',
        ),
      ),
    );
  }

  Future<void> rateCompletedTrip(Map<String, dynamic> data) async {
    final trip = currentTrip;
    if (trip == null || state is! TripCompleted) {
      emit(const TripError(message: 'التقييم متاح بعد إنهاء الرحلة فقط'));
      return;
    }

    final completed = state as TripCompleted;
    emit(const TripLoading());

    final result = await _rateTripUseCase(
      RateTripParams(tripId: trip.id, data: data),
    );

    result.fold(
      (failure) => emit(TripError(message: failure.message)),
      (message) => emit(
        TripCompleted(
          trip: completed.trip,
          payment: completed.payment,
          ratingSuccessMessage:
              message.isNotEmpty ? message : 'تم التقييم بنجاح',
        ),
      ),
    );
  }


  Future<void> acceptTrip() async {
    final trip = currentTrip;
    if (trip == null) return;

    emit(const TripLoading());

    final result = await _acceptTripUseCase(
      AcceptTripParams(tripId: trip.id),
    );

    result.fold(
      (failure) => emit(TripError(message: failure.message)),
      (status) => emit(
        DriverAccepted(
          trip: trip.copyWith(status: status),
          successMessage: 'تم قبول الرحلة',
        ),
      ),
    );
  }

  Future<void> markDriverArrived() async {
    final trip = currentTrip;
    if (trip == null) return;

    emit(const TripLoading());

    final result = await _driverArrivedUseCase(
      DriverArrivedParams(tripId: trip.id),
    );

    result.fold(
      (failure) => emit(TripError(message: failure.message)),
      (status) => emit(
        DriverArrived(
          trip: trip.copyWith(status: status),
          successMessage: 'تم تسجيل وصول السائق',
        ),
      ),
    );
  }

  Future<void> startTrip() async {
    final trip = currentTrip;
    if (trip == null) return;

    emit(const TripLoading());

    final result = await _startTripUseCase(
      StartTripParams(tripId: trip.id),
    );

    result.fold(
      (failure) => emit(TripError(message: failure.message)),
      (status) => emit(
        TripInProgress(
          trip: trip.copyWith(status: status),
          successMessage: 'بدأت الرحلة بنجاح',
        ),
      ),
    );
  }

  Future<void> updateTracking({
    required double lat,
    required double lng,
  }) async {
    final trip = currentTrip;
    if (trip == null) return;

    final result = await _updateTrackingUseCase(
      UpdateTrackingParams(tripId: trip.id, lat: lat, lng: lng),
    );

    result.fold(
      (failure) => emit(TripError(message: failure.message)),
      (tracking) {
        final current = state;
        if (current is TripInProgress) {
          emit(current.copyWith(lastTracking: tracking));
        } else if (current is DriverAccepted) {
          emit(current.copyWith(lastTracking: tracking));
        } else if (current is DriverArrived) {
          emit(current.copyWith(lastTracking: tracking));
        }
      },
    );
  }

  Future<void> completeTrip() async {
    final trip = currentTrip;
    if (trip == null) return;

    emit(const TripLoading());

    final result = await _completeTripUseCase(
      CompleteTripParams(tripId: trip.id),
    );

    result.fold(
      (failure) => emit(TripError(message: failure.message)),
      (completeResult) => emit(
        TripCompleted(
          trip: trip.copyWith(
            status: TripStatus.completed,
            fareAmount: completeResult.payment.amount,
            paymentMethod: completeResult.payment.method,
          ),
          payment: completeResult.payment,
          successMessage: completeResult.message ??
              'تم إنهاء الرحلة بنجاح وتسجيل عملية الدفع',
        ),
      ),
    );
  }

  void reset() => emit(const TripInitial());

  static double? _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static DateTime? _asDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
