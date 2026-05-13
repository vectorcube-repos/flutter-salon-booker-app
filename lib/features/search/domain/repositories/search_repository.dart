import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/search/domain/entities/search_result_data.dart';

abstract class SearchRepository {
  ResultFuture<SearchResultData> searchCatalog(String query);
}
