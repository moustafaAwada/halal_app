import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/size.dart';

class SizeModel extends Size {
  const SizeModel({
    required super.id,
    required super.name,
    required super.price,
    super.isDefault,
  });

  factory SizeModel.fromJson(Map<String, dynamic> json) {
    return SizeModel(
      id: JsonParsers.toInt(json['id']),
      name: json['name']?.toString() ?? '',
      price: JsonParsers.toDouble(json['price']),
      isDefault: JsonParsers.toBool(json['is_default']),
    );
  }

  Size toEntity() => Size(
        id: id,
        name: name,
        price: price,
        isDefault: isDefault,
      );
}
