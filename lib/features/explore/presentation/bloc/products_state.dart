part of 'products_bloc.dart';

sealed class ProductsState extends Equatable {
  const ProductsState();

  @override
  List<Object> get props => [];
}

final class ProductsInitial extends ProductsState {
  @override
  List<Object> get props => [];
}

final class ProductsLoading extends ProductsState {
  final List<Category> categories;
  final List<ProductColor> colors;
  final List<ProductMaterial> materials;
  final String selectedCategoryId;
  final String selectedMaterialId;
  final String selectedColorId;
  final String selectedSortBy;
  final double minPrice;
  final double maxPrice;

  const ProductsLoading({
    this.categories = const [],
    this.colors = const [],
    this.materials = const [],
    this.selectedCategoryId = '',
    this.selectedMaterialId = '',
    this.selectedColorId = '',
    this.selectedSortBy = 'newest',
    this.minPrice = 0,
    this.maxPrice = 400,
  });

  ProductsLoading copyWith({
    List<Category>? categories,
    List<ProductColor>? colors,
    List<ProductMaterial>? materials,
    String? selectedCategoryId,
    String? selectedMaterialId,
    String? selectedColorId,
    String? selectedSortBy,
    double? minPrice,
    double? maxPrice,
  }) {
    return ProductsLoading(
      categories: categories ?? this.categories,
      colors: colors ?? this.colors,
      materials: materials ?? this.materials,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      selectedMaterialId: selectedMaterialId ?? this.selectedMaterialId,
      selectedColorId: selectedColorId ?? this.selectedColorId,
      selectedSortBy: selectedSortBy ?? this.selectedSortBy,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
    );
  }

  @override
  List<Object> get props => [
        categories,
        colors,
        materials,
        selectedCategoryId,
        selectedMaterialId,
        selectedColorId,
        selectedSortBy,
        minPrice,
        maxPrice,
      ];
}

final class ProductsLoaded extends ProductsState {
  final List<Product> products;
  final List<Category> categories;
  final List<ProductColor> colors;
  final List<ProductMaterial> materials;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;
  final bool isLoadingMore;
  final bool hasMore;
  final String selectedCategoryId;
  final String selectedMaterialId;
  final String selectedColorId;
  final String selectedSortBy;
  final double minPrice;
  final double maxPrice;

  const ProductsLoaded({
    required this.products,
    this.categories = const [],
    this.colors = const [],
    this.materials = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
    this.perPage = 0,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.selectedCategoryId = '',
    this.selectedMaterialId = '',
    this.selectedColorId = '',
    this.selectedSortBy = 'newest',
    this.minPrice = 0,
    this.maxPrice = 400,
  });

  ProductsLoaded copyWith({
    List<Product>? products,
    List<Category>? categories,
    List<ProductColor>? colors,
    List<ProductMaterial>? materials,
    int? currentPage,
    int? lastPage,
    int? total,
    int? perPage,
    bool? isLoadingMore,
    bool? hasMore,
    String? selectedCategoryId,
    String? selectedMaterialId,
    String? selectedColorId,
    String? selectedSortBy,
    double? minPrice,
    double? maxPrice,
  }) {
    return ProductsLoaded(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      colors: colors ?? this.colors,
      materials: materials ?? this.materials,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
      perPage: perPage ?? this.perPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      selectedMaterialId: selectedMaterialId ?? this.selectedMaterialId,
      selectedColorId: selectedColorId ?? this.selectedColorId,
      selectedSortBy: selectedSortBy ?? this.selectedSortBy,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
    );
  }

  @override
  List<Object> get props => [
        products,
        categories,
        colors,
        materials,
        currentPage,
        lastPage,
        total,
        perPage,
        isLoadingMore,
        hasMore,
        selectedCategoryId,
        selectedMaterialId,
        selectedColorId,
        selectedSortBy,
        minPrice,
        maxPrice,
      ];
}

final class ProductsLoadingFailure extends ProductsState {
  final String message;

  const ProductsLoadingFailure({required this.message});

  @override
  List<Object> get props => [message];
}