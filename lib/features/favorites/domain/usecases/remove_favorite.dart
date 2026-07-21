import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/favorites_repository.dart';

class RemoveFavoriteUseCase implements UseCase<void, RemoveFavoriteParams> {
  const RemoveFavoriteUseCase(this._repository);

  final FavoritesRepository _repository;

  @override
  Future<Either<Failure, void>> call(RemoveFavoriteParams params) {
    return _repository.removeFavorite(favoriteId: params.favoriteId);
  }
}

class RemoveFavoriteParams extends Equatable {
  const RemoveFavoriteParams({required this.favoriteId});

  final int favoriteId;

  @override
  List<Object?> get props => [favoriteId];
}
