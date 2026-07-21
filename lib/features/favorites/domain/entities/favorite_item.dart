import 'package:equatable/equatable.dart';

import 'favorite_menu.dart';

class FavoriteItem extends Equatable {
  const FavoriteItem({
    required this.id,
    required this.userId,
    required this.menuId,
    required this.createdAt,
    required this.updatedAt,
    required this.menu,
  });

  final int id;
  final int userId;
  final int menuId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final FavoriteMenu menu;

  @override
  List<Object?> get props => [id, userId, menuId, createdAt, updatedAt, menu];
}
