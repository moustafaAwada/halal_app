import 'package:equatable/equatable.dart';

class SearchCategory extends Equatable {
  const SearchCategory({
    required this.key,
    required this.label,
  });

  final String key;
  final String label;

  @override
  List<Object?> get props => [key, label];
}
