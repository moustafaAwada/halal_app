import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/cart_repository.dart';

class ClearCartUseCase implements UseCase<void, NoParams> {
  const ClearCartUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return _repository.clearCart();
  }
}
