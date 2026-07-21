import 'package:equatable/equatable.dart';

class SearchProductCategory extends Equatable {
  const SearchProductCategory({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}
