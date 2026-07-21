import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/favorite_vendor.dart';

class FavoriteVendorModel extends FavoriteVendor {
  const FavoriteVendorModel({
    required super.id,
    required super.name,
  });

  factory FavoriteVendorModel.fromJson(Map<String, dynamic> json) {
    return FavoriteVendorModel(
      id: JsonParsers.toInt(json['id']),
      name: json['name'] as String? ?? '',
    );
  }

  FavoriteVendor toEntity() => FavoriteVendor(id: id, name: name);
}
