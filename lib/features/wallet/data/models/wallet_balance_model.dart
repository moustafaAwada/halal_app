import '../../domain/entities/wallet_balance.dart';

class WalletBalanceModel extends WalletBalance {
  const WalletBalanceModel({required super.balance});

  factory WalletBalanceModel.fromJson(Map<String, dynamic> json) {
    return WalletBalanceModel(
      balance: double.parse(json['balance'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'balance': balance.toString(),
    };
  }
}
