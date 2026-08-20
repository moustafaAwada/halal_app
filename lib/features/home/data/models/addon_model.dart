import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/addon.dart';

class AddonModel extends Addon {
  const AddonModel({
    required super.id,
    required super.name,
    required super.price,
    super.isDefault,
  });

  factory AddonModel.fromJson(Map<String, dynamic> json) {
    return AddonModel(
      id: JsonParsers.toInt(json['id']),
      name: json['name']?.toString() ?? '',
      price: JsonParsers.toDouble(json['price']),
      isDefault: JsonParsers.toBool(json['is_default']),
    );
  }

  Addon toEntity() => Addon(
        id: id,
        name: name,
        price: price,
        isDefault: isDefault,
      );
}
