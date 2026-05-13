import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/salon_favorites/domain/entities/favorite_salon.dart';

abstract class SalonFavoritesRepository {
  ResultFuture<List<FavoriteSalon>> getFavoriteSalons();
  ResultFuture<void> addToFavorites(int salonId);
  ResultFuture<void> removeFromFavorites(int salonId);
}
