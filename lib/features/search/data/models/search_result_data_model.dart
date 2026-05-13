import 'package:salon_booker_app/features/search/data/models/search_salon_model.dart';
import 'package:salon_booker_app/features/search/data/models/search_service_model.dart';
import 'package:salon_booker_app/features/search/domain/entities/search_result_data.dart';

class SearchResultDataModel extends SearchResultData {
  const SearchResultDataModel({super.query, super.salons, super.services});

  factory SearchResultDataModel.fromApiJson(Map<String, dynamic> json) {
    final payload = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    List<T> parseList<T>(Object? raw, T Function(Map<String, dynamic>) parser) {
      if (raw is! List) return const [];
      return raw
          .whereType<Map>()
          .map((item) => parser(Map<String, dynamic>.from(item)))
          .toList();
    }

    return SearchResultDataModel(
      query: (payload['query'] as String?)?.trim() ?? '',
      salons: parseList(payload['salons'], SearchSalonModel.fromApiJson),
      services: parseList(payload['services'], SearchServiceModel.fromApiJson),
    );
  }
}
