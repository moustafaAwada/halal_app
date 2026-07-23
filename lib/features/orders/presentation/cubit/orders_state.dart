part of 'orders_cubit.dart';

sealed class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => [];
}

final class OrdersInitial extends OrdersState {
  const OrdersInitial();
}

final class OrdersLoading extends OrdersState {
  const OrdersLoading();
}

final class OrdersLoaded extends OrdersState {
  const OrdersLoaded({
    required this.orders,
    required this.selectedStatus,
  });

  final List<Order> orders;
  final String? selectedStatus;

  @override
  List<Object?> get props => [orders, selectedStatus];
}

final class OrdersError extends OrdersState {
  const OrdersError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
