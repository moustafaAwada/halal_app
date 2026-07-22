import 'dart:convert';

import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/restaurant_detail.dart';

class RestaurantMenuItemModel extends RestaurantMenuItem {
  const RestaurantMenuItemModel({
    required super.id,
    required super.name,
    required super.description,
    required super.image,
    required super.type,
    required super.price,
    required super.priceBeforeDiscount,
    required super.discountPercentage,
    required super.originalPrice,
  });

  factory RestaurantMenuItemModel.fromJson(Map<String, dynamic> json) {
    final priceBeforeDiscount =
        JsonParsers.toDouble(json['price_before_discount']);
    final discount = JsonParsers.toDouble(json['discount_percentage']).round();

    return RestaurantMenuItemModel(
      id: JsonParsers.toInt(json['id']),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      image: json['image'] as String? ?? '',
      type: json['type'] as String? ?? 'normal',
      price: JsonParsers.toDouble(json['price']),
      priceBeforeDiscount: priceBeforeDiscount > 0 ? priceBeforeDiscount : null,
      discountPercentage: discount,
      originalPrice: JsonParsers.toDouble(json['original_price'] ?? json['price']),
    );
  }

  RestaurantMenuItem toEntity() => RestaurantMenuItem(
        id: id,
        name: name,
        description: description,
        image: image,
        type: type,
        price: price,
        priceBeforeDiscount: priceBeforeDiscount,
        discountPercentage: discountPercentage,
        originalPrice: originalPrice,
      );
}

class RestaurantCategoryModel extends RestaurantCategory {
  const RestaurantCategoryModel({
    required super.id,
    required super.name,
    required super.menus,
  });

  factory RestaurantCategoryModel.fromJson(Map<String, dynamic> json) {
    final menusJson = json['Menus'] ?? json['menus'];
    final menus = menusJson is List
        ? menusJson
            .whereType<Map>()
            .map(
              (item) => RestaurantMenuItemModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList()
        : <RestaurantMenuItemModel>[];

    return RestaurantCategoryModel(
      id: JsonParsers.toInt(json['id']),
      name: json['name'] as String? ?? '',
      menus: menus,
    );
  }

  RestaurantCategory toEntity() => RestaurantCategory(
        id: id,
        name: name,
        menus: menus
            .map(
              (menu) => (menu as RestaurantMenuItemModel).toEntity(),
            )
            .toList(),
      );
}

class RestaurantDetailModel extends RestaurantDetail {
  const RestaurantDetailModel({
    required super.id,
    required super.nameAr,
    required super.nameEn,
    required super.shortDescription,
    required super.imageUrl,
    required super.cover,
    required super.phone,
    required super.whatsapp,
    required super.openTime,
    required super.closeTime,
    required super.is24Hours,
    required super.workingDays,
    required super.pickup,
    required super.latitude,
    required super.longitude,
    required super.categories,
  });

  factory RestaurantDetailModel.fromJson(Map<String, dynamic> json) {
    final categoriesJson = json['Categories'] ?? json['categories'];
    final categories = categoriesJson is List
        ? categoriesJson
            .whereType<Map>()
            .map(
              (item) => RestaurantCategoryModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList()
        : <RestaurantCategoryModel>[];

    return RestaurantDetailModel(
      id: JsonParsers.toInt(json['id']),
      nameAr: json['name_ar'] as String? ?? '',
      nameEn: json['name_en'] as String? ?? '',
      shortDescription: json['short_description'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      cover: json['cover'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      whatsapp: json['whatsapp'] as String? ?? '',
      openTime: _normalizeNullableString(json['open_time']),
      closeTime: _normalizeNullableString(json['close_time']),
      is24Hours: JsonParsers.toBool(json['is24Hours'] ?? json['is_24_hours']),
      workingDays: _parseWorkingDays(json['working_days']),
      pickup: JsonParsers.toBool(json['pickup']),
      latitude: JsonParsers.toDouble(json['latitude']),
      longitude: JsonParsers.toDouble(json['longitude']),
      categories: categories,
    );
  }

  static String _normalizeNullableString(dynamic value) {
    if (value == null) return '';
    final text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return '';
    return text;
  }

  static List<String> _parseWorkingDays(dynamic value) {
    if (value is List) {
      return value.map((day) => day.toString()).toList();
    }

    if (value is String && value.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) {
          return decoded.map((day) => day.toString()).toList();
        }
      } catch (_) {}
    }

    return const [];
  }

  RestaurantDetail toEntity() => RestaurantDetail(
        id: id,
        nameAr: nameAr,
        nameEn: nameEn,
        shortDescription: shortDescription,
        imageUrl: imageUrl,
        cover: cover,
        phone: phone,
        whatsapp: whatsapp,
        openTime: openTime,
        closeTime: closeTime,
        is24Hours: is24Hours,
        workingDays: workingDays,
        pickup: pickup,
        latitude: latitude,
        longitude: longitude,
        categories: categories
            .map(
              (category) => (category as RestaurantCategoryModel).toEntity(),
            )
            .toList(),
      );
}
