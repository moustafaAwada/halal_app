import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.isActive,
    required this.ordersCount,
    required this.favoritesCount,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String city;
  final bool isActive;
  final int ordersCount;
  final int favoritesCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        address,
        city,
        isActive,
        ordersCount,
        favoritesCount,
        createdAt,
        updatedAt,
      ];
}
