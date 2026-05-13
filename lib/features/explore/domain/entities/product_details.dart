import 'package:equatable/equatable.dart';
import 'package:salon_booker_app/features/explore/domain/entities/category.dart';
import 'package:salon_booker_app/features/explore/domain/entities/color.dart';
import 'package:salon_booker_app/features/explore/domain/entities/material.dart';

class ProductDetails extends Equatable {
  final int id;
  final String name;
  final double price;
  final String description;
  final String photo;
  final bool isFavorite;
  final List<Category> categories;
  final List<ProductMaterial> materials;
  final List<ProductColor> colors;

  const ProductDetails({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.photo,
    required this.isFavorite,
    this.categories = const [],
    this.materials = const [],
    this.colors = const [],
  });

  ProductDetails copyWith({
    int? id,
    String? name,
    double? price,
    String? description,
    String? photo,
    bool? isFavorite,
    List<Category>? categories,
    List<ProductMaterial>? materials,
    List<ProductColor>? colors,
  }) {
    return ProductDetails(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      photo: photo ?? this.photo,
      isFavorite: isFavorite ?? this.isFavorite,
      categories: categories ?? this.categories,
      materials: materials ?? this.materials,
      colors: colors ?? this.colors,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        price,
        description,
        photo,
        isFavorite,
        categories,
        materials,
        colors,
      ];
}
