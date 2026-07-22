import 'package:equatable/equatable.dart';

class CartMenu extends Equatable {
  const CartMenu({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    this.vendorId,
    this.vendorName,
  });

  final int id;
  final String name;
  final String description;
  final double price;
  final String image;
  final int? vendorId;
  final String? vendorName;

  bool get isComplete => name.isNotEmpty || price > 0 || image.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        image,
        vendorId,
        vendorName,
      ];
}
