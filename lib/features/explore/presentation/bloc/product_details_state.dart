part of 'product_details_bloc.dart';

sealed class ProductDetailsState extends Equatable {
  const ProductDetailsState();

  @override
  List<Object?> get props => [];
}

final class ProductDetailsInitial extends ProductDetailsState {}

final class ProductDetailsLoading extends ProductDetailsState {}

final class ProductDetailsLoaded extends ProductDetailsState {
  final ProductDetails product;
  final int selectedQuantity;

  const ProductDetailsLoaded({
    required this.product,
    this.selectedQuantity = 1,
  });

  ProductDetailsLoaded copyWith({
    ProductDetails? product,
    int? selectedQuantity,
  }) {
    return ProductDetailsLoaded(
      product: product ?? this.product,
      selectedQuantity: selectedQuantity ?? this.selectedQuantity,
    );
  }

  @override
  List<Object?> get props => [product, selectedQuantity];
}

final class ProductDetailsFailure extends ProductDetailsState {
  final String message;

  const ProductDetailsFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
