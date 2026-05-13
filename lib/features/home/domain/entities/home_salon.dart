import 'package:equatable/equatable.dart';

class HomeSalon extends Equatable {
  final int id;
  final int? ownerId;
  final String name;
  final String? description;
  final String? phone;
  final String? address;
  final String? city;
  final String? state;
  final String? postalCode;
  final double? latitude;
  final double? longitude;
  final String? status;
  final String? imageThumb;
  final bool isFavorite;

  const HomeSalon({
    required this.id,
    required this.name,
    this.ownerId,
    this.description,
    this.phone,
    this.address,
    this.city,
    this.state,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.status,
    this.imageThumb,
    this.isFavorite = false,
  });

  @override
  List<Object?> get props => [
    id,
    ownerId,
    name,
    description,
    phone,
    address,
    city,
    state,
    postalCode,
    latitude,
    longitude,
    status,
    imageThumb,
    isFavorite,
  ];
}
