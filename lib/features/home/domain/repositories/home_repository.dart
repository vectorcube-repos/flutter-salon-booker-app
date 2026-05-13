import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/home/domain/entities/home_dashboard_data.dart';

abstract class HomeRepository {
  ResultFuture<HomeDashboardData> getHomeDashboard({
    required double latitude,
    required double longitude,
  });
}
