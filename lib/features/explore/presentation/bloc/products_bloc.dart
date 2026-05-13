import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salon_booker_app/core/entities/product.dart';
import 'package:salon_booker_app/features/explore/data/services/favorites_notifier.dart';
import 'package:salon_booker_app/features/explore/domain/use_cases/add_to_favorites_use_case.dart';
import 'package:salon_booker_app/features/explore/domain/use_cases/remove_from_favorites_use_case.dart';
import 'package:salon_booker_app/features/explore/domain/entities/category.dart';
import 'package:salon_booker_app/features/explore/domain/entities/color.dart';
import 'package:salon_booker_app/features/explore/domain/entities/material.dart';
import 'package:salon_booker_app/features/explore/domain/use_cases/get_products_params.dart';
import 'package:salon_booker_app/features/explore/domain/use_cases/get_products_use_case.dart';

part 'products_event.dart';
part 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final GetProductsUseCase getProductsUseCase;
  final AddToFavoritesUseCase addToFavoritesUseCase;
  final RemoveFromFavoritesUseCase removeFromFavoritesUseCase;
  final FavoritesNotifier favoritesNotifier;

  StreamSubscription<({int productId, bool isFavorite})>?
  _favoritesSubscription;

  ProductsBloc(
    this.getProductsUseCase,
    this.addToFavoritesUseCase,
    this.removeFromFavoritesUseCase,
    this.favoritesNotifier,
  ) : super(ProductsInitial()) {
    on<GetProductsEvent>(_onGetProducts);
    on<ProductCategoryChanged>(_onProductCategoryChanged);
    on<ProductFiltersUpdated>(_onProductFiltersUpdated);
    on<ProductFiltersApplied>(_onProductFiltersApplied);
    on<ProductsNextPageRequested>(_onProductsNextPageRequested);
    on<ProductFavoriteToggled>(_onProductFavoriteToggled);
    on<ProductFavoriteUpdated>(_onProductFavoriteUpdated);

    _favoritesSubscription = favoritesNotifier.favoriteChanges.listen((event) {
      add(
        ProductFavoriteUpdated(
          productId: event.productId,
          isFavorite: event.isFavorite,
        ),
      );
    });
  }

  @override
  Future<void> close() {
    _favoritesSubscription?.cancel();
    return super.close();
  }

  Future<void> _onProductFavoriteToggled(
    ProductFavoriteToggled event,
    Emitter<ProductsState> emit,
  ) async {
    if (state is! ProductsLoaded) return;
    final current = state as ProductsLoaded;
    final index = current.products.indexWhere((p) => p.id == event.productId);
    if (index < 0) return;

    final product = current.products[index];
    final newFavorite = !product.isFavorite;

    final updatedProducts = [
      ...current.products.sublist(0, index),
      Product(
        id: product.id,
        name: product.name,
        price: product.price,
        photo: product.photo,
        isFavorite: newFavorite,
      ),
      ...current.products.sublist(index + 1),
    ];
    emit(current.copyWith(products: updatedProducts));

    final result = newFavorite
        ? await addToFavoritesUseCase(event.productId)
        : await removeFromFavoritesUseCase(event.productId);

    result.fold((_) {
      emit(current.copyWith(products: current.products));
    }, (_) {});
  }

  void _onProductFavoriteUpdated(
    ProductFavoriteUpdated event,
    Emitter<ProductsState> emit,
  ) {
    if (state is! ProductsLoaded) return;
    final current = state as ProductsLoaded;
    final index = current.products.indexWhere((p) => p.id == event.productId);
    if (index < 0) return;

    final product = current.products[index];
    if (product.isFavorite == event.isFavorite) return;

    final updatedProducts = [
      ...current.products.sublist(0, index),
      Product(
        id: product.id,
        name: product.name,
        price: product.price,
        photo: product.photo,
        isFavorite: event.isFavorite,
      ),
      ...current.products.sublist(index + 1),
    ];
    emit(current.copyWith(products: updatedProducts));
  }

  Future<void> _onProductCategoryChanged(
    ProductCategoryChanged event,
    Emitter<ProductsState> emit,
  ) async {
    add(
      GetProductsEvent(
        page: 1,
        categoryId: event.categoryId,
        isInitialLoad: false,
      ),
    );
  }

  void _onProductFiltersUpdated(
    ProductFiltersUpdated event,
    Emitter<ProductsState> emit,
  ) {
    if (state is ProductsLoaded) {
      final current = state as ProductsLoaded;
      emit(
        current.copyWith(
          selectedCategoryId: event.categoryId ?? current.selectedCategoryId,
          selectedMaterialId: event.materialId ?? current.selectedMaterialId,
          selectedColorId: event.colorId ?? current.selectedColorId,
          selectedSortBy: event.sortBy ?? current.selectedSortBy,
          minPrice: event.minPrice ?? current.minPrice,
          maxPrice: event.maxPrice ?? current.maxPrice,
        ),
      );
      return;
    }

    if (state is ProductsLoading) {
      final current = state as ProductsLoading;
      emit(
        current.copyWith(
          selectedCategoryId: event.categoryId ?? current.selectedCategoryId,
          selectedMaterialId: event.materialId ?? current.selectedMaterialId,
          selectedColorId: event.colorId ?? current.selectedColorId,
          selectedSortBy: event.sortBy ?? current.selectedSortBy,
          minPrice: event.minPrice ?? current.minPrice,
          maxPrice: event.maxPrice ?? current.maxPrice,
        ),
      );
    }
  }

  void _onProductFiltersApplied(
    ProductFiltersApplied event,
    Emitter<ProductsState> emit,
  ) {
    final current = _extractFiltersFromState(state);
    add(
      GetProductsEvent(
        page: 1,
        categoryId: current.selectedCategoryId,
        materialId: current.selectedMaterialId,
        colorId: current.selectedColorId,
        sortBy: current.selectedSortBy,
        minPrice: current.minPrice,
        maxPrice: current.maxPrice,
        isInitialLoad: false,
      ),
    );
  }

  void _onProductsNextPageRequested(
    ProductsNextPageRequested event,
    Emitter<ProductsState> emit,
  ) {
    if (state is! ProductsLoaded) return;
    final current = state as ProductsLoaded;
    if (current.isLoadingMore || !current.hasMore) return;
    add(GetProductsEvent(page: current.currentPage + 1, isInitialLoad: false));
  }

  Future<void> _onGetProducts(
    GetProductsEvent event,
    Emitter<ProductsState> emit,
  ) async {
    final previousLoadedState = state is ProductsLoaded
        ? state as ProductsLoaded
        : null;
    final previousLoadingState = state is ProductsLoading
        ? state as ProductsLoading
        : null;
    final currentFilters = _extractFiltersFromState(state);

    final selectedCategoryId =
        event.categoryId ?? currentFilters.selectedCategoryId;
    final selectedMaterialId =
        event.materialId ?? currentFilters.selectedMaterialId;
    final selectedColorId = event.colorId ?? currentFilters.selectedColorId;
    final selectedSortBy = event.sortBy ?? currentFilters.selectedSortBy;
    final minPrice = event.minPrice ?? currentFilters.minPrice;
    final maxPrice = event.maxPrice ?? currentFilters.maxPrice;
    final search = event.search ?? '';
    final isLoadMore = event.page > 1 && previousLoadedState != null;

    if (isLoadMore) {
      if (previousLoadedState.isLoadingMore || !previousLoadedState.hasMore) {
        return;
      }
      emit(previousLoadedState.copyWith(isLoadingMore: true));
    } else {
      emit(
        ProductsLoading(
          categories:
              previousLoadedState?.categories ??
              previousLoadingState?.categories ??
              const [],
          colors:
              previousLoadedState?.colors ??
              previousLoadingState?.colors ??
              const [],
          materials:
              previousLoadedState?.materials ??
              previousLoadingState?.materials ??
              const [],
          selectedCategoryId: selectedCategoryId,
          selectedMaterialId: selectedMaterialId,
          selectedColorId: selectedColorId,
          selectedSortBy: selectedSortBy,
          minPrice: minPrice,
          maxPrice: maxPrice,
        ),
      );
    }

    final result = await getProductsUseCase(
      GetProductsParams(
        categoryId: selectedCategoryId,
        materialId: selectedMaterialId,
        colorId: selectedColorId,
        sortBy: selectedSortBy,
        minPrice: minPrice,
        maxPrice: maxPrice,
        search: search,
        page: event.page,
        isInitialLoad: event.isInitialLoad,
      ),
    );
    result.fold(
      (failure) {
        if (isLoadMore) {
          emit(previousLoadedState.copyWith(isLoadingMore: false));
          return;
        }
        emit(
          ProductsLoadingFailure(
            message: failure.message ?? 'An unknown error occurred',
          ),
        );
      },
      (data) => emit(
        ProductsLoaded(
          products: isLoadMore
              ? [...previousLoadedState.products, ...data.products]
              : data.products,
          categories: event.isInitialLoad || data.categories.isNotEmpty
              ? data.categories
              : (previousLoadedState?.categories ??
                    previousLoadingState?.categories ??
                    const []),
          colors: event.isInitialLoad || data.colors.isNotEmpty
              ? data.colors
              : (previousLoadedState?.colors ??
                    previousLoadingState?.colors ??
                    const []),
          materials: event.isInitialLoad || data.materials.isNotEmpty
              ? data.materials
              : (previousLoadedState?.materials ??
                    previousLoadingState?.materials ??
                    const []),
          currentPage: data.currentPage,
          lastPage: data.lastPage,
          total: data.total,
          perPage: data.perPage,
          isLoadingMore: false,
          hasMore: data.currentPage < data.lastPage,
          selectedCategoryId: selectedCategoryId,
          selectedMaterialId: selectedMaterialId,
          selectedColorId: selectedColorId,
          selectedSortBy: selectedSortBy,
          minPrice: minPrice,
          maxPrice: maxPrice,
        ),
      ),
    );
  }

  ({
    String selectedCategoryId,
    String selectedMaterialId,
    String selectedColorId,
    String selectedSortBy,
    double minPrice,
    double maxPrice,
  })
  _extractFiltersFromState(ProductsState currentState) {
    if (currentState is ProductsLoaded) {
      return (
        selectedCategoryId: currentState.selectedCategoryId,
        selectedMaterialId: currentState.selectedMaterialId,
        selectedColorId: currentState.selectedColorId,
        selectedSortBy: currentState.selectedSortBy,
        minPrice: currentState.minPrice,
        maxPrice: currentState.maxPrice,
      );
    }

    if (currentState is ProductsLoading) {
      return (
        selectedCategoryId: currentState.selectedCategoryId,
        selectedMaterialId: currentState.selectedMaterialId,
        selectedColorId: currentState.selectedColorId,
        selectedSortBy: currentState.selectedSortBy,
        minPrice: currentState.minPrice,
        maxPrice: currentState.maxPrice,
      );
    }

    return (
      selectedCategoryId: '',
      selectedMaterialId: '',
      selectedColorId: '',
      selectedSortBy: 'newest',
      minPrice: 0,
      maxPrice: 400,
    );
  }
}
