import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product_detail.dart';
import '../repositories/home_repository.dart';

class GetProductDetailsUseCase
    implements UseCase<ProductDetail, ProductDetailsParams> {
  const GetProductDetailsUseCase(this._repository);

  final HomeRepository _repository;

  @override
  Future<Either<Failure, ProductDetail>> call(ProductDetailsParams params) {
    return _repository.getProductDetails(params.id);
  }
}

class ProductDetailsParams extends Equatable {
  const ProductDetailsParams({required this.id});

  final int id;

  @override
  List<Object?> get props => [id];
}
