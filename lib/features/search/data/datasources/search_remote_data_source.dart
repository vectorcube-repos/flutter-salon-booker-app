import 'package:salon_booker_app/core/services/network/dio_client.dart';
import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/search/data/models/search_result_data_model.dart';

abstract class SearchRemoteDataSource {
  ResultFuture<SearchResultDataModel> search(String query);
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  SearchRemoteDataSourceImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  ResultFuture<SearchResultDataModel> search(String query) {
    return _dioClient.get<SearchResultDataModel>(
      '/search',
      queryParameters: {'q': query},
      parser: (data) {
        if (data is! Map<String, dynamic>) {
          throw FormatException(
            'Expected object response, got: ${data.runtimeType}',
          );
        }
        return SearchResultDataModel.fromApiJson(data);
      },
    );
  }
}
