part of 'order_details_cubit.dart';

sealed class OrderDetailsState extends Equatable {
  const OrderDetailsState();

  @override
  List<Object?> get props => [];
}

final class OrderDetailsInitial extends OrderDetailsState {
  const OrderDetailsInitial();
}

final class OrderDetailsLoading extends OrderDetailsState {
  const OrderDetailsLoading();
}

final class OrderDetailsLoaded extends OrderDetailsState {
  const OrderDetailsLoaded({required this.details});

  final OrderDetails details;

  @override
  List<Object?> get props => [details];
}

final class OrderDetailsError extends OrderDetailsState {
  const OrderDetailsError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
