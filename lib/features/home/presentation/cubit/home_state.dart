part of 'home_cubit.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

final class HomeInitial extends HomeState {
  const HomeInitial();
}

final class HomeLoading extends HomeState {
  const HomeLoading();
}

final class HomeLoaded extends HomeState {
  const HomeLoaded({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

final class HomeError extends HomeState {
  const HomeError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
