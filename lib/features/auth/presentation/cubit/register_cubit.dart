import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/register_usecase.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit({required RegisterUseCase registerUseCase})
      : _registerUseCase = registerUseCase,
        super(const RegisterInitial());

  final RegisterUseCase _registerUseCase;

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String address,
    required String city,
  }) async {
    emit(const RegisterLoading());

    final result = await _registerUseCase(
      RegisterParams(
        fullName: fullName.trim(),
        email: email.trim(),
        password: password,
        phone: phone.trim(),
        address: address.trim(),
        city: city.trim(),
      ),
    );

    result.fold(
      (failure) => emit(RegisterError(message: failure.message)),
      (_) => emit(const RegisterSuccess()),
    );
  }

  void reset() => emit(const RegisterInitial());
}
