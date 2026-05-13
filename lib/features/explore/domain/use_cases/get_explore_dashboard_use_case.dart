import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/explore/domain/entities/explore_dashboard_data.dart';
import 'package:salon_booker_app/features/explore/domain/repositories/explore_repository.dart';

class GetExploreDashboardUseCase {
  final ExploreRepository exploreRepository;

  GetExploreDashboardUseCase(this.exploreRepository);

  ResultFuture<ExploreDashboardData> call({
    String? categoryId,
    required double latitude,
    required double longitude,
    int page = 1,
    bool isInitialLoad = false,
  }) async {
    return exploreRepository.getExploreDashboard(
      categoryId: categoryId,
      latitude: latitude,
      longitude: longitude,
      page: page,
      isInitialLoad: isInitialLoad,
    );
  }
}
