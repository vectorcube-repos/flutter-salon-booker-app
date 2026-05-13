import 'package:equatable/equatable.dart';

class SalonBookingService extends Equatable {
  const SalonBookingService({
    required this.id,
    required this.name,
    this.durationMinutes,
    this.price,
    this.image,
  });

  final int id;
  final String name;
  final int? durationMinutes;
  final double? price;
  final String? image;

  @override
  List<Object?> get props => [id, name, durationMinutes, price, image];
}
