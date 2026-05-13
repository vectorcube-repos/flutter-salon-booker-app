import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/explore/domain/repositories/product_repository.dart';

class AddToFavoritesUseCase {
  final ProductRepository repository;

  AddToFavoritesUseCase(this.repository);

  ResultFuture<void> call(int productId) => repository.addToFavorites(productId);
}
