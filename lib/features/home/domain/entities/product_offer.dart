import 'product.dart';

class ProductOffer extends Product {
  const ProductOffer({
    required super.id,
    required super.name,
    required super.price,
    required super.image,
    required super.rating,
    required super.isFavorite,
    required super.totalSold,
    super.type,
    super.reviewCount,
    super.vendor,
    required this.oldPrice,
    required this.discount,
  });

  final double oldPrice;
  final int discount;

  @override
  List<Object?> get props => [...super.props, oldPrice, discount];
}
