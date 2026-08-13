import 'package:equatable/equatable.dart';

class ProductVendor extends Equatable {
  const ProductVendor({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.imageUrl,
    required this.cover,
    required this.avgRating,
  });

  final int id;
  final String nameAr;
  final String nameEn;
  final String imageUrl;
  final String cover;
  final double avgRating;

  String get displayName {
    final ar = nameAr.trim();
    if (ar.isNotEmpty) return ar;
    final en = nameEn.trim();
    if (en.isNotEmpty) return en;
    return 'مطعم';
  }

  @override
  List<Object?> get props => [id, nameAr, nameEn, imageUrl, cover, avgRating];
}
