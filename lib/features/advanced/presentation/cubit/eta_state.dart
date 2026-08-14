part of 'eta_cubit.dart';

sealed class EtaState extends Equatable {
  const EtaState();

  @override
  List<Object?> get props => [];
}

final class EtaInitial extends EtaState {
  const EtaInitial();
}

final class EtaLoading extends EtaState {
  const EtaLoading();
}

final class EtaLoaded extends EtaState {
  const EtaLoaded({required this.info});

  final ETAInfo info;

  @override
  List<Object?> get props => [info];
}

final class EtaError extends EtaState {
  const EtaError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
