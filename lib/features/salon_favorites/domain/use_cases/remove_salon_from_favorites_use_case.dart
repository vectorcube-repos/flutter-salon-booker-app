import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/salon_favorites/domain/repositories/salon_favorites_repository.dart';

class RemoveSalonFromFavoritesUseCase {
  final SalonFavoritesRepository repository;

  RemoveSalonFromFavoritesUseCase(this.repository);

  ResultFuture<void> call(int salonId) =>
      repository.removeFromFavorites(salonId);
}
