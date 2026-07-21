import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/favorite_item.dart';
import 'favorite_menu_model.dart';

class FavoriteItemModel extends FavoriteItem {
  const FavoriteItemModel({
    required super.id,
    required super.userId,
    required super.menuId,
    required super.createdAt,
    required super.updatedAt,
    required super.menu,
  });

  factory FavoriteItemModel.fromJson(Map<String, dynamic> json) {
    final menuJson = json['menu'];
    final menu = menuJson is Map
        ? FavoriteMenuModel.fromJson(Map<String, dynamic>.from(menuJson))
        : const FavoriteMenuModel(
            id: 0,
            name: '',
            description: '',
            originalPrice: 0,
            price: 0,
            image: '',
          );

    return FavoriteItemModel(
      id: JsonParsers.toInt(json['id']),
      userId: JsonParsers.toInt(json['user_id']),
      menuId: JsonParsers.toInt(json['menu_id']),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
      menu: menu,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  FavoriteItem toEntity() => FavoriteItem(
        id: id,
        userId: userId,
        menuId: menuId,
        createdAt: createdAt,
        updatedAt: updatedAt,
        menu: menu is FavoriteMenuModel
            ? (menu as FavoriteMenuModel).toEntity()
            : menu,
      );
}
