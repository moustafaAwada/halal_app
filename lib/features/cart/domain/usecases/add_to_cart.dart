import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cart_item.dart';
import '../repositories/cart_repository.dart';

class AddToCartUseCase implements UseCase<List<CartItem>, AddToCartParams> {
  const AddToCartUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<Either<Failure, List<CartItem>>> call(AddToCartParams params) {
    return _repository.addToCart(params);
  }
}

class AddToCartParams extends Equatable {
  const AddToCartParams({
    required this.productId,
    this.quantity = 1,
    this.menuSizeId,
    this.addonIds,
    this.note,
  });

  final int productId;
  final int quantity;
  final int? menuSizeId;
  final List<int>? addonIds;
  final String? note;

  @override
  List<Object?> get props => [productId, quantity, menuSizeId, addonIds, note];
}
