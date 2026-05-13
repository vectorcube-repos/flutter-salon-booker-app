import 'package:equatable/equatable.dart';

class FavoriteSalon extends Equatable {
  final int id;
  final String name;
  final String? image;
  final String? address;
  final String? city;
  final String? state;
  final String? status;
  final bool isFavorite;

  const FavoriteSalon({
    required this.id,
    required this.name,
    this.image,
    this.address,
    this.city,
    this.state,
    this.status,
    this.isFavorite = true,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    image,
    address,
    city,
    state,
    status,
    isFavorite,
  ];
}
