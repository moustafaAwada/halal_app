import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/wallet_request.dart';
import '../repositories/wallet_repository.dart';

class GetWalletRequestsUseCase {
  GetWalletRequestsUseCase(this.repository);

  final WalletRepository repository;

  Future<Either<Failure, List<WalletRequest>>> call() async {
    return repository.getMyRequests();
  }
}
