import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final int id;
  final String name;
  final double price;
  final String photo;
  final bool isFavorite;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.photo,
    this.isFavorite = false,
  });

  @override
  List<Object?> get props => [id, name, price, photo, isFavorite];
}
