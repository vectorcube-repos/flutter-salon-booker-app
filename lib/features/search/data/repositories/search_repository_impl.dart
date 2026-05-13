import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/search/data/datasources/search_remote_data_source.dart';
import 'package:salon_booker_app/features/search/domain/entities/search_result_data.dart';
import 'package:salon_booker_app/features/search/domain/repositories/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  SearchRepositoryImpl(this._remoteDataSource);

  final SearchRemoteDataSource _remoteDataSource;

  @override
  ResultFuture<SearchResultData> searchCatalog(String query) async {
    final result = await _remoteDataSource.search(query);
    return result.map((data) => data);
  }
}
