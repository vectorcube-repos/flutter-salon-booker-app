import 'package:salon_booker_app/features/explore/domain/entities/explore_pagination.dart';

class ExplorePaginationModel extends ExplorePagination {
  const ExplorePaginationModel({
    super.total,
    super.perPage,
    super.currentPage,
    super.lastPage,
    super.from,
    super.to,
  });

  factory ExplorePaginationModel.fromApiJson(Map<String, dynamic> json) {
    int parseInt(Object? value, {int fallback = 0}) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '') ?? fallback;
    }

    return ExplorePaginationModel(
      total: parseInt(json['total']),
      perPage: parseInt(json['per_page']),
      currentPage: parseInt(json['current_page'], fallback: 1),
      lastPage: parseInt(json['last_page'], fallback: 1),
      from: json['from'] == null ? null : parseInt(json['from']),
      to: json['to'] == null ? null : parseInt(json['to']),
    );
  }
}
