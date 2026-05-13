import 'package:salon_booker_app/core/services/network/dio_client.dart';
import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/explore/data/models/explore_dashboard_model.dart';

abstract class ExploreRemoteDataSource {
  ResultFuture<ExploreDashboardModel> getExploreDashboard({
    String? categoryId,
    required double latitude,
    required double longitude,
    int page = 1,
    bool isInitialLoad = false,
  });
}

class ExploreRemoteDataSourceImpl implements ExploreRemoteDataSource {
  final DioClient _dioClient;

  ExploreRemoteDataSourceImpl(this._dioClient);

  @override
  ResultFuture<ExploreDashboardModel> getExploreDashboard({
    String? categoryId,
    required double latitude,
    required double longitude,
    int page = 1,
    bool isInitialLoad = false,
  }) {
    return _dioClient.get<ExploreDashboardModel>(
      '/explore',
      queryParameters: {
        'page': page,
        'latitude': latitude,
        'longitude': longitude,
        if (isInitialLoad) 'initial': 1,
        if (categoryId != null && categoryId.isNotEmpty)
          'service_id': categoryId,
      },
      parser: (data) {
        if (data is! Map<String, dynamic>) {
          throw FormatException(
            'Expected object response, got: ${data.runtimeType}',
          );
        }
        return ExploreDashboardModel.fromApiJson(data);
      },
    );
  }
}
