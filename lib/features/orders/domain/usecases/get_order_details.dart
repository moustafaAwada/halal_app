import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/order_details.dart';
import '../repositories/orders_repository.dart';

class GetOrderDetailsUseCase
    implements UseCase<OrderDetails, GetOrderDetailsParams> {
  const GetOrderDetailsUseCase(this._repository);

  final OrdersRepository _repository;

  @override
  Future<Either<Failure, OrderDetails>> call(GetOrderDetailsParams params) {
    return _repository.getOrderDetails(params.orderId);
  }
}

class GetOrderDetailsParams extends Equatable {
  const GetOrderDetailsParams({required this.orderId});

  final int orderId;

  @override
  List<Object?> get props => [orderId];
}
