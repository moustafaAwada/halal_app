import 'package:equatable/equatable.dart';

class RestaurantMenuItem extends Equatable {
  const RestaurantMenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.type,
    required this.price,
    required this.priceBeforeDiscount,
    required this.discountPercentage,
    required this.originalPrice,
  });

  final int id;
  final String name;
  final String description;
  final String image;
  final String type;
  final double price;
  final double? priceBeforeDiscount;
  final int discountPercentage;
  final double originalPrice;

  bool get isOffer => type == 'offer';

  bool get hasDiscount =>
      discountPercentage > 0 ||
      (priceBeforeDiscount != null && priceBeforeDiscount! > price);

  double? get displayPriceBeforeDiscount {
    if (priceBeforeDiscount != null && priceBeforeDiscount! > price) {
      return priceBeforeDiscount;
    }

    if (discountPercentage > 0 && discountPercentage < 100) {
      return price / (1 - discountPercentage / 100.0);
    }

    return null;
  }

  bool get showDescription =>
      description.trim().isNotEmpty && description.trim() != name.trim();

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        image,
        type,
        price,
        priceBeforeDiscount,
        discountPercentage,
        originalPrice,
      ];
}

class RestaurantCategory extends Equatable {
  const RestaurantCategory({
    required this.id,
    required this.name,
    required this.menus,
  });

  final int id;
  final String name;
  final List<RestaurantMenuItem> menus;

  bool get hasMenus => menus.isNotEmpty;

  @override
  List<Object?> get props => [id, name, menus];
}

class RestaurantDetail extends Equatable {
  const RestaurantDetail({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.shortDescription,
    required this.imageUrl,
    required this.cover,
    required this.phone,
    required this.whatsapp,
    required this.openTime,
    required this.closeTime,
    required this.is24Hours,
    required this.workingDays,
    required this.pickup,
    required this.latitude,
    required this.longitude,
    required this.categories,
  });

  final int id;
  final String nameAr;
  final String nameEn;
  final String shortDescription;
  final String imageUrl;
  final String cover;
  final String phone;
  final String whatsapp;
  final String openTime;
  final String closeTime;
  final bool is24Hours;
  final List<String> workingDays;
  final bool pickup;
  final double latitude;
  final double longitude;
  final List<RestaurantCategory> categories;

  String get displayName {
    if (nameAr.trim().isNotEmpty) return nameAr;
    if (nameEn.trim().isNotEmpty) return nameEn;
    return 'مطعم';
  }

  List<RestaurantCategory> get categoriesWithMenus =>
      categories.where((category) => category.hasMenus).toList();

  int get menuItemsCount =>
      categoriesWithMenus.fold(0, (count, category) => count + category.menus.length);

  String get workingHoursLabel {
    if (is24Hours) return 'مفتوح 24 ساعة';

    final open = _normalizeTime(openTime);
    final close = _normalizeTime(closeTime);
    if (open != null && close != null) return '$open - $close';
    return 'غير محدد';
  }

  String get workingDaysLabel {
    if (workingDays.isEmpty || workingDays.length >= 7) {
      return 'كل أيام الأسبوع';
    }
    return workingDays.map(_dayToArabic).join(' · ');
  }

  static String? _normalizeTime(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.toLowerCase() == 'null') return null;
    return trimmed;
  }

  static String _dayToArabic(String day) {
    return switch (day.toLowerCase()) {
      'sat' => 'السبت',
      'sun' => 'الأحد',
      'mon' => 'الإثنين',
      'tue' => 'الثلاثاء',
      'wed' => 'الأربعاء',
      'thu' => 'الخميس',
      'fri' => 'الجمعة',
      _ => day,
    };
  }

  @override
  List<Object?> get props => [
        id,
        nameAr,
        nameEn,
        shortDescription,
        imageUrl,
        cover,
        phone,
        whatsapp,
        openTime,
        closeTime,
        is24Hours,
        workingDays,
        pickup,
        latitude,
        longitude,
        categories,
      ];
}
