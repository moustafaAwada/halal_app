import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/restaurant.dart';

class RestaurantModel extends Restaurant {
  const RestaurantModel({
    required super.id,
    required super.name,
    required super.imageUrl,
    required super.avgRating,
    required super.buyersCount,
    required super.menusCount,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    final name = (json['name_en'] as String?)?.trim() ?? '';
    return RestaurantModel(
      id: JsonParsers.toInt(json['id']),
      name: name.isEmpty ? 'مطعم' : name,
      imageUrl: json['image_url'] as String? ?? '',
      avgRating: JsonParsers.toDouble(json['avgRating']),
      buyersCount: JsonParsers.toInt(json['buyersCount']),
      menusCount: JsonParsers.toInt(json['menusCount']),
    );
  }

  Restaurant toEntity() => Restaurant(
        id: id,
        name: name,
        imageUrl: imageUrl,
        avgRating: avgRating,
        buyersCount: buyersCount,
        menusCount: menusCount,
      );
}
