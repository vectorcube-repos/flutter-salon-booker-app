import 'package:equatable/equatable.dart';
import 'package:salon_booker_app/core/entities/product.dart';
import 'package:salon_booker_app/features/explore/domain/entities/category.dart';
import 'package:salon_booker_app/features/explore/domain/entities/color.dart';
import 'package:salon_booker_app/features/explore/domain/entities/material.dart';

/// Domain entity holding products with filter options (categories, colors, materials).
/// Used for initial load (all data) and pagination (products only).
class ProductsPageData extends Equatable {
  final List<Product> products;
  final List<Category> categories;
  final List<ProductColor> colors;
  final List<ProductMaterial> materials;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;

  const ProductsPageData({
    required this.products,
    this.categories = const [],
    this.colors = const [],
    this.materials = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
    this.perPage = 0,
  });

  @override
  List<Object?> get props => [
        products,
        categories,
        colors,
        materials,
        currentPage,
        lastPage,
        total,
        perPage,
      ];
}
