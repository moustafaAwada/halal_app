import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/order_details.dart';
import '../../domain/usecases/get_order_details.dart';

part 'order_details_state.dart';

class OrderDetailsCubit extends Cubit<OrderDetailsState> {
  OrderDetailsCubit({required GetOrderDetailsUseCase getOrderDetailsUseCase})
      : _getOrderDetailsUseCase = getOrderDetailsUseCase,
        super(const OrderDetailsInitial());

  final GetOrderDetailsUseCase _getOrderDetailsUseCase;

  Future<void> loadOrderDetails(int orderId) async {
    emit(const OrderDetailsLoading());

    final result = await _getOrderDetailsUseCase(
      GetOrderDetailsParams(orderId: orderId),
    );

    result.fold(
      (failure) => emit(OrderDetailsError(message: failure.message)),
      (details) => emit(OrderDetailsLoaded(details: details)),
    );
  }

  Future<void> retry(int orderId) => loadOrderDetails(orderId);
}
