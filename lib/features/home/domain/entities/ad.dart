import 'package:equatable/equatable.dart';

class Ad extends Equatable {
  const Ad({
    required this.id,
    required this.title,
    required this.targetUrl,
    required this.placement,
    required this.startDate,
    required this.durationDays,
    required this.image,
    this.notes,
  });

  final int id;
  final String title;
  final String? targetUrl;
  final String placement;
  final DateTime? startDate;
  final int durationDays;
  final String? notes;
  final String image;

  @override
  List<Object?> get props => [
        id,
        title,
        targetUrl,
        placement,
        startDate,
        durationDays,
        notes,
        image,
      ];
}
