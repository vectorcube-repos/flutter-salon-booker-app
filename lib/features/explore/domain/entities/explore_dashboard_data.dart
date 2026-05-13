import 'package:equatable/equatable.dart';
import 'package:salon_booker_app/features/explore/domain/entities/explore_category.dart';
import 'package:salon_booker_app/features/explore/domain/entities/explore_pagination.dart';
import 'package:salon_booker_app/features/explore/domain/entities/explore_salon.dart';

class ExploreDashboardData extends Equatable {
  final List<ExploreSalon> salons;
  final List<ExploreCategory> services;
  final ExplorePagination pagination;

  const ExploreDashboardData({
    this.salons = const [],
    this.services = const [],
    this.pagination = const ExplorePagination(),
  });

  @override
  List<Object?> get props => [salons, services, pagination];
}
