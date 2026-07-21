import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/favorite_item.dart';

abstract class FavoritesRepository {
  Future<Either<Failure, List<FavoriteItem>>> getFavorites();

  Future<Either<Failure, FavoriteItem>> addFavorite({required int productId});

  Future<Either<Failure, void>> removeFavorite({required int favoriteId});
}
