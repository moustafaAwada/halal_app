part of 'forgot_password_cubit.dart';

sealed class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();

  @override
  List<Object?> get props => [];
}

final class ForgotPasswordInitial extends ForgotPasswordState {
  const ForgotPasswordInitial();
}

final class ForgotPasswordLoading extends ForgotPasswordState {
  const ForgotPasswordLoading();
}

final class ForgotPasswordCodeSent extends ForgotPasswordState {
  const ForgotPasswordCodeSent({required this.email});

  final String email;

  @override
  List<Object?> get props => [email];
}

final class ForgotPasswordResetSuccess extends ForgotPasswordState {
  const ForgotPasswordResetSuccess();
}

final class ForgotPasswordError extends ForgotPasswordState {
  const ForgotPasswordError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
