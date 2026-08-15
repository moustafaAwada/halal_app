import 'package:equatable/equatable.dart';

class WalletBalance extends Equatable {
  const WalletBalance({required this.balance});

  final double balance;

  @override
  List<Object?> get props => [balance];
}
