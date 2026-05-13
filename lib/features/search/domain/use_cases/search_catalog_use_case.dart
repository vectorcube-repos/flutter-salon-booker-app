import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/search/domain/entities/search_result_data.dart';
import 'package:salon_booker_app/features/search/domain/repositories/search_repository.dart';

class SearchCatalogUseCase {
  SearchCatalogUseCase(this._repository);

  final SearchRepository _repository;

  ResultFuture<SearchResultData> call(String query) {
    return _repository.searchCatalog(query);
  }
}
