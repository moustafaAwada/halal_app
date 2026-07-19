import '../../domain/entities/auth_result.dart';
import 'customer_model.dart';
import 'user_model.dart';

class AuthResultModel extends AuthResult {
  const AuthResultModel({
    required super.token,
    required super.user,
    super.customer,
  });

  factory AuthResultModel.fromJson(Map<String, dynamic> json) {
    final userJson = Map<String, dynamic>.from(json['user'] as Map);
    final rawCustomer = userJson['customer'];

    CustomerModel? customer;
    if (rawCustomer is Map) {
      customer = CustomerModel.fromJson(
        Map<String, dynamic>.from(rawCustomer),
      );
    }

    return AuthResultModel(
      token: json['token'] as String,
      user: UserModel.fromJson(userJson),
      customer: customer,
    );
  }

  Map<String, dynamic> toJson() => {
        'token': token,
        'user': {
          ...(user as UserModel).toJson(),
          'customer': customer == null
              ? null
              : (customer! as CustomerModel).toJson(),
        },
      };

  AuthResult toEntity() => AuthResult(
        token: token,
        user: (user as UserModel).toEntity(),
        customer: customer == null
            ? null
            : (customer! as CustomerModel).toEntity(),
      );
}
