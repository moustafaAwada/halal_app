import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cart_item.dart';
import '../repositories/cart_repository.dart';

class GetCartUseCase implements UseCase<List<CartItem>, NoParams> {
  const GetCartUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<Either<Failure, List<CartItem>>> call(NoParams params) {
    return _repository.getCart();
  }
}
