import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase implements UseCase<void, RegisterParams> {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, void>> call(RegisterParams params) {
    return _repository.register(
      fullName: params.fullName,
      email: params.email,
      password: params.password,
      phone: params.phone,
      address: params.address,
      city: params.city,
    );
  }
}

class RegisterParams extends Equatable {
  const RegisterParams({
    required this.fullName,
    required this.email,
    required this.password,
    required this.phone,
    required this.address,
    required this.city,
  });

  final String fullName;
  final String email;
  final String password;
  final String phone;
  final String address;
  final String city;

  @override
  List<Object?> get props => [fullName, email, password, phone, address, city];
}
