import 'package:equatable/equatable.dart';

class Restaurant extends Equatable {
  const Restaurant({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.phone,
    this.shortDescription = '',
    this.whatsapp = '',
    this.imageUrl = '',
    this.cover = '',
    this.city = '',
    this.area = '',
    this.address = '',
  });

  final int id;
  final String nameAr;
  final String nameEn;
  final String phone;
  final String shortDescription;
  final String whatsapp;
  final String imageUrl;
  final String cover;
  final String city;
  final String area;
  final String address;

  @override
  List<Object?> get props => [
        id,
        nameAr,
        nameEn,
        phone,
        shortDescription,
        whatsapp,
        imageUrl,
        cover,
        city,
        area,
        address,
      ];
}
