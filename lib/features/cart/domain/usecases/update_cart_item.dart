import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cart_item.dart';
import '../repositories/cart_repository.dart';

class UpdateCartItemUseCase
    implements UseCase<List<CartItem>, UpdateCartItemParams> {
  const UpdateCartItemUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<Either<Failure, List<CartItem>>> call(UpdateCartItemParams params) {
    return _repository.updateCartItem(params);
  }
}

class UpdateCartItemParams extends Equatable {
  const UpdateCartItemParams({
    required this.cartItemId,
    required this.quantity,
    this.menuSizeId,
    this.addonIds,
    this.note,
  });

  final int cartItemId;
  final int quantity;
  final int? menuSizeId;
  final List<int>? addonIds;
  final String? note;

  @override
  List<Object?> get props => [cartItemId, quantity, menuSizeId, addonIds, note];
}
