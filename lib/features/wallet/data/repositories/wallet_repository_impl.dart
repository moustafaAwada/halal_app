import 'dart:io';
import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/recharge_response.dart';
import '../../domain/entities/wallet_balance.dart';
import '../../domain/entities/wallet_request.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_remote_data_source.dart';

class WalletRepositoryImpl implements WalletRepository {
  WalletRepositoryImpl({required this.remoteDataSource});

  final WalletRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, WalletBalance>> getBalance() async {
    try {
      final result = await remoteDataSource.getBalance();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure(message: 'An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<WalletRequest>>> getMyRequests() async {
    try {
      final result = await remoteDataSource.getMyRequests();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure(message: 'An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, RechargeResponse>> submitRechargeRequest({
    required double amount,
    required String paymentMethod,
    required File receiptFile,
  }) async {
    try {
      final result = await remoteDataSource.submitRechargeRequest(
        amount: amount,
        paymentMethod: paymentMethod,
        receiptFile: receiptFile,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure(message: 'An unexpected error occurred'));
    }
  }
}
