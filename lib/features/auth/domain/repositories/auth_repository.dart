import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/auth_result.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResult>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String address,
    required String city,
  });

  Future<Either<Failure, void>> sendVerificationCode({
    required String email,
  });

  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String password,
    required String code,
  });

  Future<bool> isLoggedIn();

  Future<void> logout();

  Future<Either<Failure, int>> getStoredUserId();
}
