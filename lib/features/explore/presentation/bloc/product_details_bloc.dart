import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salon_booker_app/features/explore/domain/use_cases/add_to_favorites_use_case.dart';
import 'package:salon_booker_app/features/explore/domain/use_cases/remove_from_favorites_use_case.dart';
import 'package:salon_booker_app/features/explore/domain/entities/product_details.dart';
import 'package:salon_booker_app/features/explore/domain/use_cases/get_product_details_use_case.dart';

part 'product_details_event.dart';
part 'product_details_state.dart';

class ProductDetailsBloc extends Bloc<ProductDetailsEvent, ProductDetailsState> {
  final GetProductDetailsUseCase getProductDetailsUseCase;
  final AddToFavoritesUseCase addToFavoritesUseCase;
  final RemoveFromFavoritesUseCase removeFromFavoritesUseCase;

  ProductDetailsBloc(
    this.getProductDetailsUseCase,
    this.addToFavoritesUseCase,
    this.removeFromFavoritesUseCase,
  ) : super(ProductDetailsInitial()) {
    on<GetProductDetailsEvent>(_onGetProductDetails);
    on<ProductDetailsQuantityChanged>(_onProductDetailsQuantityChanged);
    on<ProductFavoriteToggled>(_onProductFavoriteToggled);
  }

  Future<void> _onProductFavoriteToggled(
    ProductFavoriteToggled event,
    Emitter<ProductDetailsState> emit,
  ) async {
    if (state is! ProductDetailsLoaded) return;
    final current = state as ProductDetailsLoaded;
    final newFavorite = !current.product.isFavorite;

    emit(current.copyWith(
      product: current.product.copyWith(isFavorite: newFavorite),
    ));

    final result = newFavorite
        ? await addToFavoritesUseCase(current.product.id)
        : await removeFromFavoritesUseCase(current.product.id);

    result.fold(
      (_) => emit(current.copyWith(product: current.product)),
      (_) {},
    );
  }

  Future<void> _onGetProductDetails(
    GetProductDetailsEvent event,
    Emitter<ProductDetailsState> emit,
  ) async {
    emit(ProductDetailsLoading());
    final result = await getProductDetailsUseCase(event.productId);
    result.fold(
      (failure) => emit(
        ProductDetailsFailure(
          message: failure.message ?? 'Failed to load product details',
        ),
      ),
      (product) => emit(ProductDetailsLoaded(product: product, selectedQuantity: 1)),
    );
  }

  void _onProductDetailsQuantityChanged(
    ProductDetailsQuantityChanged event,
    Emitter<ProductDetailsState> emit,
  ) {
    if (state is! ProductDetailsLoaded) return;
    if (event.quantity < 1) return;
    final current = state as ProductDetailsLoaded;
    emit(current.copyWith(selectedQuantity: event.quantity));
  }
}
