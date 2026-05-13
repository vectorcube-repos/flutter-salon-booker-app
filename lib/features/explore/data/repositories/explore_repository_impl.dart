import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/explore/data/datasources/explore_remote_data_source.dart';
import 'package:salon_booker_app/features/explore/domain/entities/explore_dashboard_data.dart';
import 'package:salon_booker_app/features/explore/domain/repositories/explore_repository.dart';

class ExploreRepositoryImpl implements ExploreRepository {
  final ExploreRemoteDataSource exploreRemoteDataSource;

  ExploreRepositoryImpl(this.exploreRemoteDataSource);

  @override
  ResultFuture<ExploreDashboardData> getExploreDashboard({
    String? categoryId,
    required double latitude,
    required double longitude,
    int page = 1,
    bool isInitialLoad = false,
  }) async {
    final result = await exploreRemoteDataSource.getExploreDashboard(
      categoryId: categoryId,
      latitude: latitude,
      longitude: longitude,
      page: page,
      isInitialLoad: isInitialLoad,
    );
    return result.map((data) => data);
  }
}
