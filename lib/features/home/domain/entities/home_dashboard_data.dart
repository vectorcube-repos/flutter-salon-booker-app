import 'package:equatable/equatable.dart';
import 'package:salon_booker_app/features/home/domain/entities/home_latest_booking.dart';
import 'package:salon_booker_app/features/home/domain/entities/home_salon.dart';
import 'package:salon_booker_app/features/home/domain/entities/home_service.dart';

class HomeDashboardData extends Equatable {
  final List<HomeService> services;
  final List<HomeSalon> salons;
  final List<HomeService> mostBookedServices;
  final HomeLatestBooking? latestBooking;

  const HomeDashboardData({
    this.services = const [],
    this.salons = const [],
    this.mostBookedServices = const [],
    this.latestBooking,
  });

  @override
  List<Object?> get props => [
    services,
    salons,
    mostBookedServices,
    latestBooking,
  ];
}
