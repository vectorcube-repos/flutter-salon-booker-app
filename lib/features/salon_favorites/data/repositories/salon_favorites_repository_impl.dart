import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/salon_favorites/data/datasources/salon_favorites_remote_data_source.dart';
import 'package:salon_booker_app/features/salon_favorites/domain/entities/favorite_salon.dart';
import 'package:salon_booker_app/features/salon_favorites/domain/repositories/salon_favorites_repository.dart';

class SalonFavoritesRepositoryImpl implements SalonFavoritesRepository {
  final SalonFavoritesRemoteDataSource remoteDataSource;

  SalonFavoritesRepositoryImpl(this.remoteDataSource);

  @override
  ResultFuture<List<FavoriteSalon>> getFavoriteSalons() {
    return remoteDataSource.getFavoriteSalons();
  }

  @override
  ResultFuture<void> addToFavorites(int salonId) {
    return remoteDataSource.addToFavorites(salonId);
  }

  @override
  ResultFuture<void> removeFromFavorites(int salonId) {
    return remoteDataSource.removeFromFavorites(salonId);
  }
}
