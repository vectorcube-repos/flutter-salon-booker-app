import 'package:salon_booker_app/features/search/domain/entities/search_service.dart';

class SearchServiceModel extends SearchService {
  const SearchServiceModel({
    required super.id,
    required super.name,
    super.description,
    super.durationMinutes,
    super.formattedRate,
    super.activeSalonsCount,
    super.image,
  });

  factory SearchServiceModel.fromApiJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId : int.tryParse('$rawId');
    if (id == null) {
      throw const FormatException('Search service id is required');
    }

    final rawDuration = json['duration_minutes'];
    final durationMinutes = rawDuration is int
        ? rawDuration
        : int.tryParse('$rawDuration');
    final rawCount = json['active_salons_count'];
    final activeSalonsCount = rawCount is int
        ? rawCount
        : int.tryParse('$rawCount');

    return SearchServiceModel(
      id: id,
      name: (json['name'] as String?)?.trim().isNotEmpty == true
          ? (json['name'] as String).trim()
          : 'Service',
      description: (json['description'] as String?)?.trim(),
      durationMinutes: durationMinutes,
      formattedRate: (json['formatted_rate'] as String?)?.trim(),
      activeSalonsCount: activeSalonsCount,
      image: (json['image'] as String?)?.trim(),
    );
  }
}
