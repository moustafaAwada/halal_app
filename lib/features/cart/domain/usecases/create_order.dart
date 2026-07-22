import 'package:dartz/dartz.dart' hide Order;

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/order.dart';
import '../repositories/cart_repository.dart';

class CreateOrderUseCase implements UseCase<List<Order>, NoParams> {
  const CreateOrderUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<Either<Failure, List<Order>>> call(NoParams params) {
    return _repository.createOrder();
  }
}
