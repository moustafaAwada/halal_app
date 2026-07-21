import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/favorite_item.dart';
import '../repositories/favorites_repository.dart';

class GetFavoritesUseCase implements UseCase<List<FavoriteItem>, NoParams> {
  const GetFavoritesUseCase(this._repository);

  final FavoritesRepository _repository;

  @override
  Future<Either<Failure, List<FavoriteItem>>> call(NoParams params) {
    return _repository.getFavorites();
  }
}
