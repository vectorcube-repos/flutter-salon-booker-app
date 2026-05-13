import 'package:equatable/equatable.dart';
import 'package:salon_booker_app/features/search/domain/entities/search_salon.dart';
import 'package:salon_booker_app/features/search/domain/entities/search_service.dart';

class SearchResultData extends Equatable {
  const SearchResultData({
    this.query = '',
    this.salons = const [],
    this.services = const [],
  });

  final String query;
  final List<SearchSalon> salons;
  final List<SearchService> services;

  bool get isEmpty => salons.isEmpty && services.isEmpty;

  @override
  List<Object?> get props => [query, salons, services];
}
