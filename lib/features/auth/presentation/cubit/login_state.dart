part of 'login_cubit.dart';

sealed class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

final class LoginInitial extends LoginState {
  const LoginInitial();
}

final class LoginLoading extends LoginState {
  const LoginLoading();
}

final class LoginSuccess extends LoginState {
  const LoginSuccess({required this.authResult});

  final AuthResult authResult;

  @override
  List<Object?> get props => [authResult];
}

final class LoginError extends LoginState {
  const LoginError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
