import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/favorite_item.dart';
import '../repositories/favorites_repository.dart';

class AddFavoriteUseCase implements UseCase<FavoriteItem, AddFavoriteParams> {
  const AddFavoriteUseCase(this._repository);

  final FavoritesRepository _repository;

  @override
  Future<Either<Failure, FavoriteItem>> call(AddFavoriteParams params) {
    return _repository.addFavorite(productId: params.productId);
  }
}

class AddFavoriteParams extends Equatable {
  const AddFavoriteParams({required this.productId});

  final int productId;

  @override
  List<Object?> get props => [productId];
}
