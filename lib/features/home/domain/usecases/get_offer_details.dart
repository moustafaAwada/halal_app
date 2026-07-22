import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product_detail.dart';
import '../repositories/home_repository.dart';

class GetOfferDetailsUseCase implements UseCase<ProductDetail, OfferDetailsParams> {
  const GetOfferDetailsUseCase(this._repository);

  final HomeRepository _repository;

  @override
  Future<Either<Failure, ProductDetail>> call(OfferDetailsParams params) {
    return _repository.getOfferDetails(params.id);
  }
}

class OfferDetailsParams extends Equatable {
  const OfferDetailsParams({required this.id});

  final int id;

  @override
  List<Object?> get props => [id];
}
