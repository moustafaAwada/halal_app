import 'package:dartz/dartz.dart' hide Order;
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/order.dart';
import '../repositories/orders_repository.dart';

class GetOrdersUseCase implements UseCase<List<Order>, GetOrdersParams> {
  const GetOrdersUseCase(this._repository);

  final OrdersRepository _repository;

  @override
  Future<Either<Failure, List<Order>>> call(GetOrdersParams params) {
    return _repository.getOrders(status: params.status);
  }
}

class GetOrdersParams extends Equatable {
  const GetOrdersParams({this.status});

  final String? status;

  @override
  List<Object?> get props => [status];
}
