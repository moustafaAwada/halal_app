import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/restaurant.dart';

class RestaurantModel extends Restaurant {
  const RestaurantModel({
    required super.id,
    required super.nameAr,
    required super.nameEn,
    required super.phone,
    super.shortDescription,
    super.whatsapp,
    super.imageUrl,
    super.cover,
    super.city,
    super.area,
    super.address,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: JsonParsers.toInt(json['id']),
      nameAr: json['name_ar']?.toString() ?? '',
      nameEn: json['name_en']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      shortDescription: json['short_description']?.toString() ?? '',
      whatsapp: json['whatsapp']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      cover: json['cover']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      area: json['area']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name_ar': nameAr,
        'name_en': nameEn,
        'phone': phone,
        'short_description': shortDescription,
        'whatsapp': whatsapp,
        'image_url': imageUrl,
        'cover': cover,
        'city': city,
        'area': area,
        'address': address,
      };

  Restaurant toEntity() => Restaurant(
        id: id,
        nameAr: nameAr,
        nameEn: nameEn,
        phone: phone,
        shortDescription: shortDescription,
        whatsapp: whatsapp,
        imageUrl: imageUrl,
        cover: cover,
        city: city,
        area: area,
        address: address,
      );
}
