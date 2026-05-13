import 'package:salon_booker_app/core/services/network/dio_client.dart';
import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/salon_favorites/data/models/favorite_salon_model.dart';

abstract class SalonFavoritesRemoteDataSource {
  ResultFuture<List<FavoriteSalonModel>> getFavoriteSalons();
  ResultFuture<void> addToFavorites(int salonId);
  ResultFuture<void> removeFromFavorites(int salonId);
}

class SalonFavoritesRemoteDataSourceImpl
    implements SalonFavoritesRemoteDataSource {
  final DioClient _dioClient;

  SalonFavoritesRemoteDataSourceImpl(this._dioClient);

  @override
  ResultFuture<List<FavoriteSalonModel>> getFavoriteSalons() {
    return _dioClient.get<List<FavoriteSalonModel>>(
      '/favorites',
      parser: (data) {
        if (data is! Map<String, dynamic>) return <FavoriteSalonModel>[];

        final payload = data['data'] is Map<String, dynamic>
            ? data['data'] as Map<String, dynamic>
            : data;

        final rawList = payload['favorites'] is List
            ? payload['favorites'] as List
            : payload['salons'] is List
            ? payload['salons'] as List
            : data['data'] is List
            ? data['data'] as List
            : const <dynamic>[];

        return rawList
            .whereType<Map>()
            .map(
              (item) => FavoriteSalonModel.fromApiJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      },
    );
  }

  @override
  ResultFuture<void> addToFavorites(int salonId) {
    return _dioClient.post<void>(
      '/favorites',
      data: {'salon_id': salonId},
      parser: (_) {},
    );
  }

  @override
  ResultFuture<void> removeFromFavorites(int salonId) {
    return _dioClient.delete<void>('/favorites/$salonId', parser: (_) {});
  }
}
