import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_wallet_balance.dart';
import '../../domain/usecases/get_wallet_requests.dart';
import '../../domain/usecases/submit_recharge.dart';
import 'wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  WalletCubit({
    required this.getWalletBalanceUseCase,
    required this.getWalletRequestsUseCase,
    required this.submitRechargeUseCase,
  }) : super(const WalletState());

  final GetWalletBalanceUseCase getWalletBalanceUseCase;
  final GetWalletRequestsUseCase getWalletRequestsUseCase;
  final SubmitRechargeUseCase submitRechargeUseCase;

  Future<void> loadWalletData() async {
    emit(state.copyWith(status: WalletStatus.loading));

    final balanceResult = await getWalletBalanceUseCase();
    final requestsResult = await getWalletRequestsUseCase();

    balanceResult.fold(
      (failure) => emit(state.copyWith(
        status: WalletStatus.error,
        errorMessage: failure.message,
      )),
      (balance) {
        requestsResult.fold(
          (failure) => emit(state.copyWith(
            status: WalletStatus.error,
            errorMessage: failure.message,
          )),
          (requests) {
            emit(state.copyWith(
              status: WalletStatus.loaded,
              balance: balance.balance,
              requests: requests,
            ));
          },
        );
      },
    );
  }

  Future<void> submitRechargeRequest({
    required double amount,
    required String paymentMethod,
    required File receipt,
  }) async {
    emit(state.copyWith(rechargeStatus: WalletRechargeStatus.submitting));

    final result = await submitRechargeUseCase(
      amount: amount,
      paymentMethod: paymentMethod,
      receiptFile: receipt,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          rechargeStatus: WalletRechargeStatus.error,
          rechargeMessage: failure.message,
        ));
      },
      (response) {
        emit(state.copyWith(
          rechargeStatus: WalletRechargeStatus.success,
          rechargeMessage: response.message,
        ));
        // Reload wallet data to get updated requests if needed
        loadWalletData();
      },
    );
  }

  void resetRechargeStatus() {
    emit(state.copyWith(
      rechargeStatus: WalletRechargeStatus.initial,
      rechargeMessage: null,
    ));
  }
}
