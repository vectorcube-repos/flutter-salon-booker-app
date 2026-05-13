import 'package:salon_booker_app/features/explore/data/models/explore_category_model.dart';
import 'package:salon_booker_app/features/explore/data/models/explore_pagination_model.dart';
import 'package:salon_booker_app/features/explore/data/models/explore_salon_model.dart';
import 'package:salon_booker_app/features/explore/domain/entities/explore_dashboard_data.dart';

class ExploreDashboardModel extends ExploreDashboardData {
  const ExploreDashboardModel({super.salons, super.services, super.pagination});

  factory ExploreDashboardModel.fromApiJson(Map<String, dynamic> json) {
    final payload = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    List<T> parseList<T>(Object? raw, T Function(Map<String, dynamic>) parser) {
      final source = raw is Map<String, dynamic> && raw['data'] is List
          ? raw['data']
          : raw;
      if (source is! List) return const [];
      return source
          .whereType<Map>()
          .map((item) => parser(Map<String, dynamic>.from(item)))
          .toList();
    }

    final salonsPayload = payload['salons'];
    final salonsData = salonsPayload is Map<String, dynamic>
        ? salonsPayload['data']
        : salonsPayload;
    final salonsMeta = salonsPayload is Map<String, dynamic>
        ? salonsPayload['meta']
        : null;

    return ExploreDashboardModel(
      salons: parseList(salonsData, ExploreSalonModel.fromApiJson),
      services: parseList(
        payload['services'] ?? payload['categories'],
        ExploreCategoryModel.fromApiJson,
      ),
      pagination: salonsMeta is Map<String, dynamic>
          ? ExplorePaginationModel.fromApiJson(salonsMeta)
          : const ExplorePaginationModel(),
    );
  }
}
