import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/salon_favorites/domain/entities/favorite_salon.dart';
import 'package:salon_booker_app/features/salon_favorites/domain/repositories/salon_favorites_repository.dart';

class GetFavoriteSalonsUseCase {
  final SalonFavoritesRepository repository;

  GetFavoriteSalonsUseCase(this.repository);

  ResultFuture<List<FavoriteSalon>> call() => repository.getFavoriteSalons();
}
