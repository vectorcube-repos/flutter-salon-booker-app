import 'package:salon_booker_app/core/services/network/dio_client.dart';
import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/home/data/models/home_dashboard_model.dart';

abstract class HomeRemoteDataSource {
  ResultFuture<HomeDashboardModel> getHomeDashboard({
    required double latitude,
    required double longitude,
  });
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final DioClient _dioClient;

  HomeRemoteDataSourceImpl(this._dioClient);

  @override
  ResultFuture<HomeDashboardModel> getHomeDashboard({
    required double latitude,
    required double longitude,
  }) {
    return _dioClient.get<HomeDashboardModel>(
      '/home',
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
      },
      parser: (data) {
        if (data is! Map<String, dynamic>) {
          throw FormatException(
              'Expected object response, got: ${data.runtimeType}');
        }
        return HomeDashboardModel.fromApiJson(data);
      },
    );
  }
}
