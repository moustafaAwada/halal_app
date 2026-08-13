part of 'rating_cubit.dart';

sealed class RatingState extends Equatable {
  const RatingState();

  @override
  List<Object?> get props => [];
}

final class RatingInitial extends RatingState {
  const RatingInitial();
}

final class RatingLoading extends RatingState {
  const RatingLoading();
}

final class RatingSuccess extends RatingState {
  const RatingSuccess({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

final class RatingError extends RatingState {
  const RatingError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
