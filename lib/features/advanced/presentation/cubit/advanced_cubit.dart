import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../trip/domain/entities/trip.dart';
import '../../../trip/domain/entities/trip_options.dart';
import '../../domain/usecases/advanced_start_trip.dart';
import '../../domain/usecases/get_nearby_trips.dart';
import '../../domain/usecases/rebook_trip.dart';
import '../../domain/usecases/verify_and_complete_delivery.dart';

part 'advanced_state.dart';

class AdvancedCubit extends Cubit<AdvancedState> {
  AdvancedCubit({
    required RebookTripUseCase rebookTripUseCase,
    required GetNearbyTripsUseCase getNearbyTripsUseCase,
    required AdvancedStartTripUseCase advancedStartTripUseCase,
    required VerifyAndCompleteDeliveryUseCase verifyAndCompleteDeliveryUseCase,
  })  : _rebookTripUseCase = rebookTripUseCase,
        _getNearbyTripsUseCase = getNearbyTripsUseCase,
        _advancedStartTripUseCase = advancedStartTripUseCase,
        _verifyAndCompleteDeliveryUseCase = verifyAndCompleteDeliveryUseCase,
        super(const AdvancedInitial());

  final RebookTripUseCase _rebookTripUseCase;
  final GetNearbyTripsUseCase _getNearbyTripsUseCase;
  final AdvancedStartTripUseCase _advancedStartTripUseCase;
  final VerifyAndCompleteDeliveryUseCase _verifyAndCompleteDeliveryUseCase;

  Future<void> rebookTrip(int tripId) async {
    emit(const AdvancedLoading());

    final result = await _rebookTripUseCase(RebookTripParams(tripId: tripId));

    result.fold(
      (failure) => emit(AdvancedError(message: failure.message)),
      (trip) => emit(AdvancedRebookSuccess(trip: trip)),
    );
  }

  Future<void> loadNearbyTrips({
    required double lat,
    required double lng,
    double radius = 3,
  }) async {
    emit(const AdvancedLoading());

    final result = await _getNearbyTripsUseCase(
      GetNearbyTripsParams(lat: lat, lng: lng, radius: radius),
    );

    result.fold(
      (failure) => emit(AdvancedError(message: failure.message)),
      (trips) => emit(AdvancedNearbyLoaded(trips: trips)),
    );
  }

  Future<void> startTrip(int tripId) async {
    emit(const AdvancedLoading());

    final result = await _advancedStartTripUseCase(
      AdvancedStartTripParams(tripId: tripId),
    );

    result.fold(
      (failure) => emit(AdvancedError(message: failure.message)),
      (_) => emit(
        const AdvancedActionSuccess(message: 'تم بدء الرحلة بنجاح'),
      ),
    );
  }

  /// Visa/card: pass [pin]. Cash/other: omit pin.
  Future<void> verifyAndCompleteDelivery({
    required int orderId,
    String? pin,
  }) async {
    emit(const AdvancedLoading());

    final result = await _verifyAndCompleteDeliveryUseCase(
      VerifyAndCompleteDeliveryParams(orderId: orderId, pin: pin),
    );

    result.fold(
      (failure) => emit(AdvancedError(message: failure.message)),
      (message) => emit(AdvancedActionSuccess(message: message)),
    );
  }

  /// Branches on payment method: card/visa requires PIN via caller UI.
  Future<void> completeDelivery({
    required int orderId,
    required String paymentMethod,
    String? pin,
  }) async {
    if (TripPaymentMethod.requiresDeliveryPin(paymentMethod)) {
      final trimmed = pin?.trim() ?? '';
      if (trimmed.length != 4) {
        emit(const AdvancedError(message: 'أدخل الرقم السري المكون من 4 أرقام'));
        return;
      }
      await verifyAndCompleteDelivery(orderId: orderId, pin: trimmed);
      return;
    }

    await verifyAndCompleteDelivery(orderId: orderId);
  }

  static bool requiresDeliveryPin(String paymentMethod) =>
      TripPaymentMethod.requiresDeliveryPin(paymentMethod);
}
