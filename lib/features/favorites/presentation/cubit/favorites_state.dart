part of 'favorites_cubit.dart';

sealed class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

final class FavoritesInitial extends FavoritesState {
  const FavoritesInitial();
}

final class FavoritesLoading extends FavoritesState {
  const FavoritesLoading();
}

final class FavoritesLoaded extends FavoritesState {
  const FavoritesLoaded({required this.favorites});

  final List<FavoriteItem> favorites;

  @override
  List<Object?> get props => [favorites];
}

final class FavoritesError extends FavoritesState {
  const FavoritesError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

final class FavoritesActionError extends FavoritesState {
  const FavoritesActionError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
