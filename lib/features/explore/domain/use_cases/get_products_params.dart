import 'package:equatable/equatable.dart';

class GetProductsParams extends Equatable {
  final String categoryId;
  final String materialId;
  final String colorId;
  final String sortBy;
  final double minPrice;
  final double maxPrice;
  final String search;
  final int page;
  final bool isInitialLoad;

  const GetProductsParams({
    required this.categoryId,
    this.materialId = '',
    this.colorId = '',
    this.sortBy = 'newest',
    this.minPrice = 0,
    this.maxPrice = 400,
    required this.search,
    required this.page,
    this.isInitialLoad = false,
  });

  @override
  List<Object?> get props => [
        categoryId,
        materialId,
        colorId,
        sortBy,
        minPrice,
        maxPrice,
        search,
        page,
        isInitialLoad,
      ];
}