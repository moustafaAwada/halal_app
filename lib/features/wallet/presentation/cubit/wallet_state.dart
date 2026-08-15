import 'package:equatable/equatable.dart';
import '../../domain/entities/wallet_request.dart';

enum WalletStatus { initial, loading, loaded, error }
enum WalletRechargeStatus { initial, submitting, success, error }

class WalletState extends Equatable {
  const WalletState({
    this.status = WalletStatus.initial,
    this.balance = 0.0,
    this.requests = const [],
    this.errorMessage,
    this.rechargeStatus = WalletRechargeStatus.initial,
    this.rechargeMessage,
  });

  final WalletStatus status;
  final double balance;
  final List<WalletRequest> requests;
  final String? errorMessage;

  final WalletRechargeStatus rechargeStatus;
  final String? rechargeMessage;

  WalletState copyWith({
    WalletStatus? status,
    double? balance,
    List<WalletRequest>? requests,
    String? errorMessage,
    WalletRechargeStatus? rechargeStatus,
    String? rechargeMessage,
  }) {
    return WalletState(
      status: status ?? this.status,
      balance: balance ?? this.balance,
      requests: requests ?? this.requests,
      errorMessage: errorMessage ?? this.errorMessage,
      rechargeStatus: rechargeStatus ?? this.rechargeStatus,
      rechargeMessage: rechargeMessage ?? this.rechargeMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        balance,
        requests,
        errorMessage,
        rechargeStatus,
        rechargeMessage,
      ];
}
