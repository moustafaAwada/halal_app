import 'package:equatable/equatable.dart';

/// Represents an optional add-on for a product (e.g., extra drink, sauce).
class Addon extends Equatable {
  const Addon({
    required this.id,
    required this.name,
    required this.price,
    this.isDefault = false,
  });

  final int id;
  final String name;

  /// The additional price added on top of the selected size price.
  final double price;
  final bool isDefault;

  @override
  List<Object?> get props => [id, name, price, isDefault];
}
