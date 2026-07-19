import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, AuthResult>> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _remoteDataSource.login(
        email: email,
        password: password,
      );
      await _localDataSource.saveToken(result.token);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return const Left(ServerFailure(message: 'حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, void>> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String address,
    required String city,
  }) async {
    try {
      await _remoteDataSource.register(
        fullName: fullName,
        email: email,
        password: password,
        phone: phone,
        address: address,
        city: city,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return const Left(ServerFailure(message: 'حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, void>> sendVerificationCode({
    required String email,
  }) async {
    try {
      await _remoteDataSource.sendVerificationCode(email: email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return const Left(ServerFailure(message: 'حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String password,
    required String code,
  }) async {
    try {
      await _remoteDataSource.resetPassword(
        email: email,
        password: password,
        code: code,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return const Left(ServerFailure(message: 'حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<bool> isLoggedIn() => _localDataSource.hasToken();

  @override
  Future<void> logout() => _localDataSource.deleteToken();
}
