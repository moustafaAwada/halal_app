import 'package:equatable/equatable.dart';

/// Order or delivery rating returned by the Ratings API.
class Rating extends Equatable {
  const Rating({
    required this.id,
    required this.orderId,
    required this.ratingValue,
    this.comment,
  });

  final int id;
  final int orderId;
  final int ratingValue;
  final String? comment;

  @override
  List<Object?> get props => [id, orderId, ratingValue, comment];
}
