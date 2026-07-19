import 'package:equatable/equatable.dart';

import 'customer.dart';
import 'user.dart';

class AuthResult extends Equatable {
  const AuthResult({
    required this.token,
    required this.user,
    this.customer,
  });

  final String token;
  final User user;
  final Customer? customer;

  @override
  List<Object?> get props => [token, user, customer];
}
