part of 'product_details_bloc.dart';

sealed class ProductDetailsEvent extends Equatable {
  const ProductDetailsEvent();

  @override
  List<Object?> get props => [];
}

final class GetProductDetailsEvent extends ProductDetailsEvent {
  final int productId;

  const GetProductDetailsEvent({required this.productId});

  @override
  List<Object?> get props => [productId];
}

final class ProductDetailsQuantityChanged extends ProductDetailsEvent {
  final int quantity;

  const ProductDetailsQuantityChanged({required this.quantity});

  @override
  List<Object?> get props => [quantity];
}

final class ProductFavoriteToggled extends ProductDetailsEvent {
  const ProductFavoriteToggled();
}
