import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/order.dart';
import '../../domain/usecases/get_orders.dart';

part 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit({required GetOrdersUseCase getOrdersUseCase})
      : _getOrdersUseCase = getOrdersUseCase,
        super(const OrdersInitial());

  final GetOrdersUseCase _getOrdersUseCase;

  String? _selectedStatus;

  String? get selectedStatus => _selectedStatus;

  Future<void> loadOrders({String? status}) async {
    _selectedStatus = status;
    emit(const OrdersLoading());

    final result = await _getOrdersUseCase(GetOrdersParams(status: status));

    result.fold(
      (failure) => emit(OrdersError(message: failure.message)),
      (orders) => emit(OrdersLoaded(orders: orders, selectedStatus: status)),
    );
  }

  Future<void> filterByStatus(String? status) => loadOrders(status: status);

  Future<void> retry() => loadOrders(status: _selectedStatus);
}
