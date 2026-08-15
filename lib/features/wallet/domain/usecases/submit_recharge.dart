import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/recharge_response.dart';
import '../repositories/wallet_repository.dart';

class SubmitRechargeUseCase {
  SubmitRechargeUseCase(this.repository);

  final WalletRepository repository;

  Future<Either<Failure, RechargeResponse>> call({
    required double amount,
    required String paymentMethod,
    required File receiptFile,
  }) async {
    return repository.submitRechargeRequest(
      amount: amount,
      paymentMethod: paymentMethod,
      receiptFile: receiptFile,
    );
  }
}
