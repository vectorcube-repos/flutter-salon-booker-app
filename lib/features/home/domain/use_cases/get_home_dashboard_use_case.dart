import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/home/domain/entities/home_dashboard_data.dart';
import 'package:salon_booker_app/features/home/domain/repositories/home_repository.dart';

class GetHomeDashboardUseCase {
  final HomeRepository homeRepository;

  GetHomeDashboardUseCase(this.homeRepository);

  ResultFuture<HomeDashboardData> call({
    required double latitude,
    required double longitude,
  }) async {
    return homeRepository.getHomeDashboard(
      latitude: latitude,
      longitude: longitude,
    );
  }
}
