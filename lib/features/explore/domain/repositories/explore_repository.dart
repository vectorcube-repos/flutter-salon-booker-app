import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/explore/domain/entities/explore_dashboard_data.dart';

abstract class ExploreRepository {
  ResultFuture<ExploreDashboardData> getExploreDashboard({
    String? categoryId,
    required double latitude,
    required double longitude,
    int page = 1,
    bool isInitialLoad = false,
  });
}
