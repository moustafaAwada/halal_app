import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/wallet_balance.dart';
import '../repositories/wallet_repository.dart';

class GetWalletBalanceUseCase {
  GetWalletBalanceUseCase(this.repository);

  final WalletRepository repository;

  Future<Either<Failure, WalletBalance>> call() async {
    return repository.getBalance();
  }
}
