import 'dart:io';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/recharge_response.dart';
import '../entities/wallet_balance.dart';
import '../entities/wallet_request.dart';

abstract class WalletRepository {
  Future<Either<Failure, WalletBalance>> getBalance();
  Future<Either<Failure, List<WalletRequest>>> getMyRequests();
  Future<Either<Failure, RechargeResponse>> submitRechargeRequest({
    required double amount,
    required String paymentMethod,
    required File receiptFile,
  });
}
