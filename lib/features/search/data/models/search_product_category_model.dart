import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/search_product_category.dart';

class SearchProductCategoryModel extends SearchProductCategory {
  const SearchProductCategoryModel({
    required super.id,
    required super.name,
  });

  factory SearchProductCategoryModel.fromJson(Map<String, dynamic> json) {
    return SearchProductCategoryModel(
      id: JsonParsers.toInt(json['id']),
      name: json['name'] as String? ?? '',
    );
  }

  SearchProductCategory toEntity() => SearchProductCategory(
        id: id,
        name: name,
      );
}
