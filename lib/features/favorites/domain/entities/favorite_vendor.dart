import 'package:equatable/equatable.dart';

class FavoriteVendor extends Equatable {
  const FavoriteVendor({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}
