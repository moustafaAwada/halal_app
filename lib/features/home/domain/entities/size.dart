import 'package:equatable/equatable.dart';

/// Represents a size option available for a product (e.g., S, M, L).
class Size extends Equatable {
  const Size({
    required this.id,
    required this.name,
    required this.price,
    this.isDefault = false,
  });

  final int id;
  final String name;

  /// The full unit price for this size (not a delta — replaces the base price).
  final double price;
  final bool isDefault;

  @override
  List<Object?> get props => [id, name, price, isDefault];
}
