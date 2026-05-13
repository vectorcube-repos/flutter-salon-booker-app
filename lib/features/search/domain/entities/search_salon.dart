import 'package:equatable/equatable.dart';

class SearchSalon extends Equatable {
  const SearchSalon({
    required this.id,
    required this.name,
    this.description,
    this.address,
    this.city,
    this.state,
    this.image,
    this.rating,
    this.reviewsCount = 0,
    this.isFavorite = false,
  });

  final int id;
  final String name;
  final String? description;
  final String? address;
  final String? city;
  final String? state;
  final String? image;
  final double? rating;
  final int reviewsCount;
  final bool isFavorite;

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    address,
    city,
    state,
    image,
    rating,
    reviewsCount,
    isFavorite,
  ];
}
