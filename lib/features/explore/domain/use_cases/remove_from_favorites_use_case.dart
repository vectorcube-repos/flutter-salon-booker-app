import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/explore/domain/repositories/product_repository.dart';

class RemoveFromFavoritesUseCase {
  final ProductRepository repository;

  RemoveFromFavoritesUseCase(this.repository);

  ResultFuture<void> call(int productId) =>
      repository.removeFromFavorites(productId);
}
