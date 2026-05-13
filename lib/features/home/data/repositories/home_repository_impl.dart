import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/home/data/datasources/home_remote_data_source.dart';
import 'package:salon_booker_app/features/home/domain/entities/home_dashboard_data.dart';
import 'package:salon_booker_app/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource homeRemoteDataSource;

  HomeRepositoryImpl(this.homeRemoteDataSource);

  @override
  ResultFuture<HomeDashboardData> getHomeDashboard({
    required double latitude,
    required double longitude,
  }) async {
    final result = await homeRemoteDataSource.getHomeDashboard(
      latitude: latitude,
      longitude: longitude,
    );
    return result.map((data) => data);
  }
}
