import 'package:equatable/equatable.dart';

class Restaurant extends Equatable {
  const Restaurant({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.phone,
  });

  final int id;
  final String nameAr;
  final String nameEn;
  final String phone;

  @override
  List<Object?> get props => [id, nameAr, nameEn, phone];
}
