import 'package:equatable/equatable.dart';
import 'package:salon_booker_app/features/home/domain/entities/home_salon.dart';
import 'package:salon_booker_app/features/home/domain/entities/home_service.dart';
import 'package:salon_booker_app/features/home/domain/entities/home_service_provider.dart';

class HomeLatestBooking extends Equatable {
  final int id;
  final String? status;
  final String? notes;
  final String? slotStart;
  final String? slotEnd;
  final HomeSalon? salon;
  final HomeService? service;
  final HomeServiceProvider? serviceProvider;

  const HomeLatestBooking({
    required this.id,
    this.status,
    this.notes,
    this.slotStart,
    this.slotEnd,
    this.salon,
    this.service,
    this.serviceProvider,
  });

  @override
  List<Object?> get props => [
    id,
    status,
    notes,
    slotStart,
    slotEnd,
    salon,
    service,
    serviceProvider,
  ];
}
