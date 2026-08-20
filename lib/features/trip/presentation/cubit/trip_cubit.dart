import 'dart:async';
import 'dart:developer' as developer;

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
import '../../domain/usecases/get_trip_details.dart';
import '../../domain/usecases/rate_trip.dart';
import '../../domain/usecases/request_trip.dart';
import '../../domain/usecases/start_trip.dart';
import '../../domain/usecases/update_tracking.dart';

part 'trip_state.dart';

const _kPollingInterval = Duration(seconds: 4);

const _kTerminalStatuses = {
  TripStatus.completed,
  TripStatus.cancelledByCustomer,
  TripStatus.cancelledByDriver,
  TripStatus.noDriverFound,
};

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
    required GetTripDetailsUseCase getTripDetailsUseCase,
  })  : _requestTripUseCase = requestTripUseCase,
        _cancelTripUseCase = cancelTripUseCase,
        _rateTripUseCase = rateTripUseCase,
        _acceptTripUseCase = acceptTripUseCase,
        _driverArrivedUseCase = driverArrivedUseCase,
        _startTripUseCase = startTripUseCase,
        _updateTrackingUseCase = updateTrackingUseCase,
        _completeTripUseCase = completeTripUseCase,
        _getTripDetailsUseCase = getTripDetailsUseCase,
        super(const TripInitial());

  final RequestTripUseCase _requestTripUseCase;
  final CancelTripUseCase _cancelTripUseCase;
  final RateTripUseCase _rateTripUseCase;
  final AcceptTripUseCase _acceptTripUseCase;
  final DriverArrivedUseCase _driverArrivedUseCase;
  final StartTripUseCase _startTripUseCase;
  final UpdateTrackingUseCase _updateTrackingUseCase;
  final CompleteTripUseCase _completeTripUseCase;
  final GetTripDetailsUseCase _getTripDetailsUseCase;

  Timer? _pollingTimer;

  // ─── Helpers ────────────────────────────────────────────────────────────────

  Trip? get currentTrip => switch (state) {
        TripRequested(:final trip) => trip,
        TripSearchingForDriver(:final trip) => trip,
        DriverAccepted(:final trip) => trip,
        DriverArrived(:final trip) => trip,
        TripInProgress(:final trip) => trip,
        TripCompleted(:final trip) => trip,
        TripCancelled(:final trip) => trip,
        NoDriverFound(:final trip) => trip,
        _ => null,
      };

  // ─── Public API ─────────────────────────────────────────────────────────────

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

        if (enriched.status == TripStatus.noDriverFound) {
          emit(NoDriverFound(trip: enriched));
        } else {
          final successMessage =
              isPrebooking ? 'تم حجز الرحلة بنجاح' : 'تم طلب الرحلة بنجاح';
          emit(TripSearchingForDriver(
            trip: enriched,
            successMessage: successMessage,
          ));
          startTrackingTrip(enriched.id);
        }
      },
    );
  }


  void startTrackingTrip(int tripId) {
    _stopPolling();

    developer.log(
      'Polling started for trip $tripId (every ${_kPollingInterval.inSeconds}s)',
      name: 'TripCubit',
    );

    _pollTripStatus(tripId);

    _pollingTimer = Timer.periodic(_kPollingInterval, (_) async {
      await _pollTripStatus(tripId);
    });
  }

  Future<void> _pollTripStatus(int tripId) async {
    if (isClosed) return;

    final result = await _getTripDetailsUseCase(tripId);

    result.fold(
      (failure) {
        // Log silently — don't interrupt the UI with polling errors.
        developer.log(
          'Polling error for trip $tripId: ${failure.message}',
          name: 'TripCubit',
        );
      },
      (updatedTrip) {
        if (isClosed) return;

        // Stop polling for terminal statuses.
        if (_kTerminalStatuses.contains(updatedTrip.status)) {
          _stopPolling();
        }

        _emitStateFromTrip(updatedTrip);
      },
    );
  }

  void _emitStateFromTrip(Trip trip) {
    developer.log(
      'Trip status updated to: ${trip.status.apiValue}',
      name: 'TripCubit',
    );
    switch (trip.status) {
      case TripStatus.requested:
        emit(TripSearchingForDriver(trip: trip));
      case TripStatus.accepted:
        // Preserve existing tracking data if the state hasn't changed category.
        final existingTracking = switch (state) {
          DriverAccepted(:final lastTracking) => lastTracking,
          _ => null,
        };
        emit(DriverAccepted(trip: trip, lastTracking: existingTracking));
      case TripStatus.driverArrived:
        final existingTracking = switch (state) {
          DriverArrived(:final lastTracking) => lastTracking,
          _ => null,
        };
        emit(DriverArrived(trip: trip, lastTracking: existingTracking));
      case TripStatus.inProgress:
        final existingTracking = switch (state) {
          TripInProgress(:final lastTracking) => lastTracking,
          _ => null,
        };
        emit(TripInProgress(trip: trip, lastTracking: existingTracking));
      case TripStatus.noDriverFound:
        emit(NoDriverFound(trip: trip));
      case TripStatus.cancelledByCustomer || TripStatus.cancelledByDriver:
        emit(TripCancelled(
          trip: trip,
          successMessage: trip.status == TripStatus.cancelledByDriver
              ? 'تم إلغاء الرحلة من قِبل السائق'
              : null,
        ));
      case TripStatus.completed:
        break;
    }
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  // ─── Existing actions ────────────────────────────────────────────────────────

  Future<void> cancelCurrentTrip(String reason) async {
    final trip = currentTrip;
    if (trip == null) {
      emit(const TripError(message: 'لا توجد رحلة نشطة للإلغاء'));
      return;
    }

    _stopPolling();
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

    _stopPolling();
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

  void reset() {
    _stopPolling();
    emit(const TripInitial());
  }

  /// Applies a trip returned from rebook API into the active lifecycle.
  void applyRebookedTrip(Trip trip) {
    emit(
      TripSearchingForDriver(
        trip: trip,
        successMessage: 'تم إعادة الحجز بنجاح',
      ),
    );
    startTrackingTrip(trip.id);
  }

  @override
  Future<void> close() {
    _stopPolling();
    return super.close();
  }

  // ─── Static helpers ──────────────────────────────────────────────────────────

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
