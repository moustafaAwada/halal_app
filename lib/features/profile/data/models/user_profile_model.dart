import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.address,
    required super.city,
    required super.isActive,
    required super.ordersCount,
    required super.favoritesCount,
    super.createdAt,
    super.updatedAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: JsonParsers.toInt(json['user_id'] ?? json['id']),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      isActive: JsonParsers.toBool(json['isActive']),
      ordersCount: JsonParsers.toInt(json['ordersCount']),
      favoritesCount: JsonParsers.toInt(json['favoritesCount']),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toUpdateJson({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? city,
  }) {
    final data = <String, dynamic>{};

    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (phone != null) data['phone'] = phone;
    if (address != null) data['address'] = address;
    if (city != null) data['city'] = city;

    return data;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  UserProfile toEntity() => UserProfile(
        id: id,
        name: name,
        email: email,
        phone: phone,
        address: address,
        city: city,
        isActive: isActive,
        ordersCount: ordersCount,
        favoritesCount: favoritesCount,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
