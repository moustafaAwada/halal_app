import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/cart_repository.dart';

class RemoveCartItemUseCase implements UseCase<void, RemoveCartItemParams> {
  const RemoveCartItemUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<Either<Failure, void>> call(RemoveCartItemParams params) {
    return _repository.removeCartItem(cartItemId: params.cartItemId);
  }
}

class RemoveCartItemParams extends Equatable {
  const RemoveCartItemParams({required this.cartItemId});

  final int cartItemId;

  @override
  List<Object?> get props => [cartItemId];
}
