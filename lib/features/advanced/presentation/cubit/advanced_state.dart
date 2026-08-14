part of 'advanced_cubit.dart';

sealed class AdvancedState extends Equatable {
  const AdvancedState();

  @override
  List<Object?> get props => [];
}

final class AdvancedInitial extends AdvancedState {
  const AdvancedInitial();
}

final class AdvancedLoading extends AdvancedState {
  const AdvancedLoading();
}

final class AdvancedRebookSuccess extends AdvancedState {
  const AdvancedRebookSuccess({
    required this.trip,
    this.message = 'تم إعادة الحجز بنجاح',
  });

  final Trip trip;
  final String message;

  @override
  List<Object?> get props => [trip, message];
}

final class AdvancedNearbyLoaded extends AdvancedState {
  const AdvancedNearbyLoaded({required this.trips});

  final List<Trip> trips;

  @override
  List<Object?> get props => [trips];
}

final class AdvancedActionSuccess extends AdvancedState {
  const AdvancedActionSuccess({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

final class AdvancedError extends AdvancedState {
  const AdvancedError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
