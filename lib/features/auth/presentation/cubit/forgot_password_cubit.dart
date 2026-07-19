import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/send_verification_code_usecase.dart';

part 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit({
    required SendVerificationCodeUseCase sendVerificationCodeUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
  })  : _sendVerificationCodeUseCase = sendVerificationCodeUseCase,
        _resetPasswordUseCase = resetPasswordUseCase,
        super(const ForgotPasswordInitial());

  final SendVerificationCodeUseCase _sendVerificationCodeUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;

  Future<void> sendCode({required String email}) async {
    emit(const ForgotPasswordLoading());

    final result = await _sendVerificationCodeUseCase(
      SendCodeParams(email: email.trim()),
    );

    result.fold(
      (failure) => emit(ForgotPasswordError(message: failure.message)),
      (_) => emit(ForgotPasswordCodeSent(email: email.trim())),
    );
  }

  Future<void> resetPassword({
    required String email,
    required String password,
    required String code,
  }) async {
    emit(const ForgotPasswordLoading());

    final result = await _resetPasswordUseCase(
      ResetPasswordParams(
        email: email.trim(),
        password: password,
        code: code.trim(),
      ),
    );

    result.fold(
      (failure) => emit(ForgotPasswordError(message: failure.message)),
      (_) => emit(const ForgotPasswordResetSuccess()),
    );
  }

  void reset() => emit(const ForgotPasswordInitial());
}
