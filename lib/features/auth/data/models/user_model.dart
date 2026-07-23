import '../../domain/entities/user.dart';
import '../../../../core/utils/json_parsers.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: JsonParsers.toInt(json['user_id'] ?? json['id']),
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
      };

  User toEntity() => User(
        id: id,
        name: name,
        email: email,
        role: role,
      );
}
