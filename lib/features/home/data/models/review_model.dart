import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/review.dart';
import 'review_user_model.dart';

class ReviewModel extends Review {
  const ReviewModel({
    required super.id,
    required super.rating,
    required super.comment,
    required super.createdAt,
    required super.user,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    return ReviewModel(
      id: JsonParsers.toInt(json['id']),
      rating: JsonParsers.toInt(json['rating']),
      comment: json['comment'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      user: userJson is Map
          ? ReviewUserModel.fromJson(Map<String, dynamic>.from(userJson))
          : const ReviewUserModel(id: 0, name: ''),
    );
  }

  Review toEntity() => Review(
        id: id,
        rating: rating,
        comment: comment,
        createdAt: createdAt,
        user: (user as ReviewUserModel).toEntity(),
      );
}
