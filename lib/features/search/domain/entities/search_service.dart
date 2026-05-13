import 'package:equatable/equatable.dart';

class SearchService extends Equatable {
  const SearchService({
    required this.id,
    required this.name,
    this.description,
    this.durationMinutes,
    this.formattedRate,
    this.activeSalonsCount,
    this.image,
  });

  final int id;
  final String name;
  final String? description;
  final int? durationMinutes;
  final String? formattedRate;
  final int? activeSalonsCount;
  final String? image;

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    durationMinutes,
    formattedRate,
    activeSalonsCount,
    image,
  ];
}
