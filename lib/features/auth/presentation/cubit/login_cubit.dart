import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/auth_result.dart';
import '../../domain/usecases/login_usecase.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({required LoginUseCase loginUseCase})
      : _loginUseCase = loginUseCase,
        super(const LoginInitial());

  final LoginUseCase _loginUseCase;

  Future<void> login({required String email, required String password}) async {
    emit(const LoginLoading());

    final result = await _loginUseCase(
      LoginParams(email: email.trim(), password: password),
    );

    result.fold(
      (failure) => emit(LoginError(message: failure.message)),
      (authResult) => emit(LoginSuccess(authResult: authResult)),
    );
  }

  void reset() => emit(const LoginInitial());
}
