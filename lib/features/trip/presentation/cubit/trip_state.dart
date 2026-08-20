part of 'trip_cubit.dart';

sealed class TripState extends Equatable {
  const TripState();

  String? get successMessage => null;

  @override
  List<Object?> get props => [];
}

final class TripInitial extends TripState {
  const TripInitial();
}

final class TripLoading extends TripState {
  const TripLoading();
}

/// Emitted immediately after a trip is created and while the backend is
/// searching for an available driver. This replaces the old [TripRequested]
/// as the "waiting" state so the UI can show a pulsing search indicator.
final class TripSearchingForDriver extends TripState {
  const TripSearchingForDriver({
    required this.trip,
    this.successMessage,
  });

  final Trip trip;

  @override
  final String? successMessage;

  @override
  List<Object?> get props => [trip, successMessage];
}

/// Legacy alias kept for backward-compatibility with any code that still
/// pattern-matches on [TripRequested]. Points to the same data as
/// [TripSearchingForDriver].
final class TripRequested extends TripState {
  const TripRequested({
    required this.trip,
    this.successMessage,
  });

  final Trip trip;

  @override
  final String? successMessage;

  @override
  List<Object?> get props => [trip, successMessage];
}

final class DriverAccepted extends TripState {
  const DriverAccepted({
    required this.trip,
    this.lastTracking,
    this.successMessage,
  });

  final Trip trip;
  final TripTracking? lastTracking;

  @override
  final String? successMessage;

  DriverAccepted copyWith({
    Trip? trip,
    TripTracking? lastTracking,
    String? successMessage,
  }) {
    return DriverAccepted(
      trip: trip ?? this.trip,
      lastTracking: lastTracking ?? this.lastTracking,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [trip, lastTracking, successMessage];
}

final class DriverArrived extends TripState {
  const DriverArrived({
    required this.trip,
    this.lastTracking,
    this.successMessage,
  });

  final Trip trip;
  final TripTracking? lastTracking;

  @override
  final String? successMessage;

  DriverArrived copyWith({
    Trip? trip,
    TripTracking? lastTracking,
    String? successMessage,
  }) {
    return DriverArrived(
      trip: trip ?? this.trip,
      lastTracking: lastTracking ?? this.lastTracking,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [trip, lastTracking, successMessage];
}

final class TripInProgress extends TripState {
  const TripInProgress({
    required this.trip,
    this.lastTracking,
    this.successMessage,
  });

  final Trip trip;
  final TripTracking? lastTracking;

  @override
  final String? successMessage;

  TripInProgress copyWith({
    Trip? trip,
    TripTracking? lastTracking,
    String? successMessage,
  }) {
    return TripInProgress(
      trip: trip ?? this.trip,
      lastTracking: lastTracking ?? this.lastTracking,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [trip, lastTracking, successMessage];
}

final class TripCompleted extends TripState {
  const TripCompleted({
    required this.trip,
    required this.payment,
    this.successMessage,
    this.ratingSuccessMessage,
  });

  final Trip trip;
  final Payment payment;

  @override
  final String? successMessage;

  final String? ratingSuccessMessage;

  @override
  List<Object?> get props =>
      [trip, payment, successMessage, ratingSuccessMessage];
}

final class TripCancelled extends TripState {
  const TripCancelled({
    required this.trip,
    this.successMessage,
  });

  final Trip trip;

  @override
  final String? successMessage;

  @override
  List<Object?> get props => [trip, successMessage];
}

final class NoDriverFound extends TripState {
  const NoDriverFound({required this.trip});

  final Trip trip;

  @override
  List<Object?> get props => [trip];
}

final class TripError extends TripState {
  const TripError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
