import 'package:equatable/equatable.dart';

import 'product.dart';
import 'product_offer.dart';
import 'product_vendor.dart';

class ProductDetail extends Equatable {
  const ProductDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.price,
    required this.priceBeforeDiscount,
    required this.discountPercentage,
    required this.type,
    this.vendorId,
    this.categoryId,
    this.rating = 0,
    this.reviewCount = 0,
    this.totalSold = 0,
    this.isFavorite = false,
    this.vendor,
  });

  final int id;
  final String name;
  final String description;
  final String image;
  final double price;
  final double? priceBeforeDiscount;
  final int discountPercentage;
  final String type;
  final int? vendorId;
  final int? categoryId;
  final double rating;
  final int reviewCount;
  final int totalSold;
  final bool isFavorite;
  final ProductVendor? vendor;

  bool get isOffer => type == 'offer';

  bool get hasDiscount => discountPercentage > 0;

  int? get resolvedVendorId => vendor?.id ?? vendorId;

  double? get displayPriceBeforeDiscount {
    if (priceBeforeDiscount != null && priceBeforeDiscount! > price) {
      return priceBeforeDiscount;
    }

    if (discountPercentage > 0 && discountPercentage < 100) {
      return price / (1 - discountPercentage / 100.0);
    }

    return null;
  }

  factory ProductDetail.fromProduct(Product product) {
    final offer = product is ProductOffer ? product : null;

    return ProductDetail(
      id: product.id,
      name: product.name,
      description: '',
      image: product.image,
      price: product.price,
      priceBeforeDiscount: offer?.oldPrice,
      discountPercentage: offer?.discount ?? 0,
      type: offer != null && product.type == 'normal' ? 'offer' : product.type,
      vendorId: product.vendor?.id,
      rating: product.rating,
      reviewCount: product.reviewCount,
      totalSold: product.totalSold,
      isFavorite: product.isFavorite,
      vendor: product.vendor,
    );
  }

  ProductDetail mergeWith(ProductDetail other) {
    return ProductDetail(
      id: id,
      name: name.isNotEmpty ? name : other.name,
      description: description.isNotEmpty ? description : other.description,
      image: image.isNotEmpty ? image : other.image,
      price: price > 0 ? price : other.price,
      priceBeforeDiscount: priceBeforeDiscount ?? other.priceBeforeDiscount,
      discountPercentage:
          discountPercentage > 0 ? discountPercentage : other.discountPercentage,
      type: type.isNotEmpty ? type : other.type,
      vendorId: vendorId ?? other.vendorId,
      categoryId: categoryId ?? other.categoryId,
      rating: rating > 0 ? rating : other.rating,
      reviewCount: reviewCount > 0 ? reviewCount : other.reviewCount,
      totalSold: totalSold > 0 ? totalSold : other.totalSold,
      isFavorite: isFavorite || other.isFavorite,
      vendor: vendor ?? other.vendor,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        image,
        price,
        priceBeforeDiscount,
        discountPercentage,
        type,
        vendorId,
        categoryId,
        rating,
        reviewCount,
        totalSold,
        isFavorite,
        vendor,
      ];
}
