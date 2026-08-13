import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/rating.dart';

class RatingModel extends Rating {
  const RatingModel({
    required super.id,
    required super.orderId,
    required super.ratingValue,
    super.comment,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      id: JsonParsers.toInt(json['id']),
      orderId: JsonParsers.toInt(json['orderId']),
      ratingValue: JsonParsers.toInt(json['ratingValue']),
      comment: json['comment']?.toString(),
    );
  }

  Rating toEntity() => Rating(
        id: id,
        orderId: orderId,
        ratingValue: ratingValue,
        comment: comment,
      );
}
