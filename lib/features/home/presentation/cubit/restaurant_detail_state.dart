part of 'restaurant_detail_cubit.dart';

sealed class RestaurantDetailState extends Equatable {
  const RestaurantDetailState();

  @override
  List<Object?> get props => [];
}

final class RestaurantDetailInitial extends RestaurantDetailState {
  const RestaurantDetailInitial();
}

final class RestaurantDetailLoading extends RestaurantDetailState {
  const RestaurantDetailLoading();
}

final class RestaurantDetailLoaded extends RestaurantDetailState {
  const RestaurantDetailLoaded({required this.detail});

  final RestaurantDetail detail;

  @override
  List<Object?> get props => [detail];
}

final class RestaurantDetailError extends RestaurantDetailState {
  const RestaurantDetailError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
