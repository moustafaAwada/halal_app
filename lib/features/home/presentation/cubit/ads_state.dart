part of 'ads_cubit.dart';

sealed class AdsState extends Equatable {
  const AdsState();

  @override
  List<Object?> get props => [];
}

final class AdsInitial extends AdsState {
  const AdsInitial();
}

final class AdsLoading extends AdsState {
  const AdsLoading();
}

final class AdsLoaded extends AdsState {
  const AdsLoaded({required this.ads});

  final List<Ad> ads;

  @override
  List<Object?> get props => [ads];
}

final class AdsError extends AdsState {
  const AdsError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
