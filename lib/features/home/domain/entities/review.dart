import 'package:equatable/equatable.dart';

import 'review_user.dart';

class Review extends Equatable {
  const Review({
    required this.id,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.user,
  });

  final int id;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final ReviewUser user;

  @override
  List<Object?> get props => [id, rating, comment, createdAt, user];
}
