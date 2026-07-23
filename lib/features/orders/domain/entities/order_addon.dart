import 'package:equatable/equatable.dart';

class OrderAddon extends Equatable {
  const OrderAddon({
    required this.id,
    required this.name,
    required this.price,
  });

  final int id;
  final String name;
  final double price;

  @override
  List<Object?> get props => [id, name, price];
}
