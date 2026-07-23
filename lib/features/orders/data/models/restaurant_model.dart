import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/restaurant.dart';

class RestaurantModel extends Restaurant {
  const RestaurantModel({
    required super.id,
    required super.nameAr,
    required super.nameEn,
    required super.phone,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: JsonParsers.toInt(json['id']),
      nameAr: json['name_ar']?.toString() ?? '',
      nameEn: json['name_en']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name_ar': nameAr,
        'name_en': nameEn,
        'phone': phone,
      };

  Restaurant toEntity() => Restaurant(
        id: id,
        nameAr: nameAr,
        nameEn: nameEn,
        phone: phone,
      );
}
