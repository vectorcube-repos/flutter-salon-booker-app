import 'package:salon_booker_app/core/entities/product.dart';
import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/explore/domain/repositories/product_repository.dart';

class GetFavoritesUseCase {
  final ProductRepository repository;

  GetFavoritesUseCase(this.repository);

  ResultFuture<List<Product>> call() => repository.getFavorites();
}
