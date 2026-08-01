import '../../domain/entities/rating.dart';

class RatingModel extends Rating {
  const RatingModel({
    required super.ratedUserId,
    required super.ratingValue,
    super.comment,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      ratedUserId: _asInt(json['ratedUserId']) ?? 0,
      ratingValue: _asInt(json['ratingValue']) ?? 0,
      comment: json['comment']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ratedUserId': ratedUserId,
      'ratingValue': ratingValue,
      if (comment != null) 'comment': comment,
    };
  }

  Rating toEntity() => Rating(
        ratedUserId: ratedUserId,
        ratingValue: ratingValue,
        comment: comment,
      );

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
