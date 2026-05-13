import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/salon_favorites/domain/repositories/salon_favorites_repository.dart';

class AddSalonToFavoritesUseCase {
  final SalonFavoritesRepository repository;

  AddSalonToFavoritesUseCase(this.repository);

  ResultFuture<void> call(int salonId) => repository.addToFavorites(salonId);
}
