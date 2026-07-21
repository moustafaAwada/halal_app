import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/review_user.dart';

class ReviewUserModel extends ReviewUser {
  const ReviewUserModel({required super.id, required super.name});

  factory ReviewUserModel.fromJson(Map<String, dynamic> json) {
    return ReviewUserModel(
      id: JsonParsers.toInt(json['id']),
      name: json['name'] as String? ?? '',
    );
  }

  ReviewUser toEntity() => ReviewUser(id: id, name: name);
}
