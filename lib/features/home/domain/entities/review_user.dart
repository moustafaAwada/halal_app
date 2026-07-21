import 'package:equatable/equatable.dart';

class ReviewUser extends Equatable {
  const ReviewUser({required this.id, required this.name});

  final int id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}
