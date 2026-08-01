import 'package:equatable/equatable.dart';

class Rating extends Equatable {
  const Rating({
    required this.ratedUserId,
    required this.ratingValue,
    this.comment,
  });

  final int ratedUserId;
  final int ratingValue;
  final String? comment;

  @override
  List<Object?> get props => [ratedUserId, ratingValue, comment];
}
