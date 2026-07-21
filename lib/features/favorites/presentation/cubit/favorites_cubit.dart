import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/favorite_item.dart';
import '../../domain/usecases/add_favorite.dart';
import '../../domain/usecases/get_favorites.dart';
import '../../domain/usecases/remove_favorite.dart';

part 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit({
    required GetFavoritesUseCase getFavoritesUseCase,
    required AddFavoriteUseCase addFavoriteUseCase,
    required RemoveFavoriteUseCase removeFavoriteUseCase,
  })  : _getFavoritesUseCase = getFavoritesUseCase,
        _addFavoriteUseCase = addFavoriteUseCase,
        _removeFavoriteUseCase = removeFavoriteUseCase,
        super(const FavoritesInitial());

  final GetFavoritesUseCase _getFavoritesUseCase;
  final AddFavoriteUseCase _addFavoriteUseCase;
  final RemoveFavoriteUseCase _removeFavoriteUseCase;

  Future<void> loadFavorites() async {
    emit(const FavoritesLoading());

    final result = await _getFavoritesUseCase(const NoParams());

    result.fold(
      (failure) => emit(FavoritesError(message: failure.message)),
      (favorites) => emit(FavoritesLoaded(favorites: favorites)),
    );
  }

  Future<void> retry() => loadFavorites();

  Future<void> addFavorite(int productId) async {
    final result = await _addFavoriteUseCase(
      AddFavoriteParams(productId: productId),
    );

    result.fold(
      (failure) => emit(FavoritesActionError(message: failure.message)),
      (item) {
        final currentState = state;
        if (currentState is FavoritesLoaded) {
          if (currentState.favorites.any((favorite) => favorite.menuId == productId)) {
            return;
          }
          emit(
            FavoritesLoaded(
              favorites: [...currentState.favorites, item],
            ),
          );
        } else {
          emit(FavoritesLoaded(favorites: [item]));
        }
      },
    );
  }

  Future<void> toggleFavorite(int productId) async {
    final currentState = state;
    if (currentState is FavoritesLoaded) {
      for (final favorite in currentState.favorites) {
        if (favorite.menuId == productId) {
          await removeFavorite(favorite.id);
          return;
        }
      }
    }

    await addFavorite(productId);
  }

  bool isProductFavorite(int productId) {
    final currentState = state;
    if (currentState is FavoritesLoaded) {
      return currentState.favorites.any((favorite) => favorite.menuId == productId);
    }
    return false;
  }

  Future<void> removeFavorite(int favoriteId) async {
    final currentState = state;
    if (currentState is! FavoritesLoaded) return;

    final previousFavorites = currentState.favorites;
    final updatedFavorites = previousFavorites
        .where((item) => item.id != favoriteId)
        .toList();

    emit(FavoritesLoaded(favorites: updatedFavorites));

    final result = await _removeFavoriteUseCase(
      RemoveFavoriteParams(favoriteId: favoriteId),
    );

    result.fold(
      (failure) {
        emit(FavoritesActionError(message: failure.message));
        emit(FavoritesLoaded(favorites: previousFavorites));
      },
      (_) {},
    );
  }

  Future<void> removeAllFavorites() async {
    final currentState = state;
    if (currentState is! FavoritesLoaded || currentState.favorites.isEmpty) {
      return;
    }

    final previousFavorites = List<FavoriteItem>.from(currentState.favorites);
    emit(const FavoritesLoaded(favorites: []));

    for (final item in previousFavorites) {
      final result = await _removeFavoriteUseCase(
        RemoveFavoriteParams(favoriteId: item.id),
      );

      final failed = result.fold(
        (failure) {
          emit(FavoritesActionError(message: failure.message));
          emit(FavoritesLoaded(favorites: previousFavorites));
          return true;
        },
        (_) => false,
      );

      if (failed) return;
    }
  }
}
