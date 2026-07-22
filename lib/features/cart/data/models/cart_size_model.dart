import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/cart_size.dart';

class CartSizeModel extends CartSize {
  const CartSizeModel({
    required super.id,
    required super.name,
    required super.price,
  });

  factory CartSizeModel.fromJson(Map<String, dynamic> json) {
    return CartSizeModel(
      id: JsonParsers.toInt(json['id']),
      name: json['name']?.toString() ?? '',
      price: JsonParsers.toDouble(json['price']),
    );
  }

  CartSize toEntity() => CartSize(id: id, name: name, price: price);
}
