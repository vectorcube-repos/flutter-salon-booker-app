import 'package:salon_booker_app/features/home/data/models/home_salon_model.dart';
import 'package:salon_booker_app/features/home/data/models/home_service_model.dart';
import 'package:salon_booker_app/features/home/data/models/home_service_provider_model.dart';
import 'package:salon_booker_app/features/home/domain/entities/home_latest_booking.dart';

class HomeLatestBookingModel extends HomeLatestBooking {
  const HomeLatestBookingModel({
    required super.id,
    super.status,
    super.notes,
    super.slotStart,
    super.slotEnd,
    super.salon,
    super.service,
    super.serviceProvider,
  });

  factory HomeLatestBookingModel.fromApiJson(Map<String, dynamic> json) {
    final idRaw = json['id'];
    if (idRaw == null) {
      throw const FormatException('Home latest booking id is required');
    }

    final id = idRaw is int ? idRaw : int.tryParse(idRaw.toString());
    if (id == null) {
      throw const FormatException(
        'Home latest booking id must be a valid integer',
      );
    }

    String? parseNullableString(Object? value) {
      final text = value?.toString().trim();
      if (text == null || text.isEmpty) return null;
      return text;
    }

    final salonJson = json['salon'];
    final serviceJson = json['service'];
    final serviceProviderJson = json['service_provider'];

    return HomeLatestBookingModel(
      id: id,
      status: parseNullableString(json['status']),
      notes: parseNullableString(json['notes']),
      slotStart: parseNullableString(json['slot_start']),
      slotEnd: parseNullableString(json['slot_end']),
      salon: salonJson is Map<String, dynamic>
          ? HomeSalonModel.fromApiJson(salonJson)
          : null,
      service: serviceJson is Map<String, dynamic>
          ? HomeServiceModel.fromApiJson(serviceJson)
          : null,
      serviceProvider: serviceProviderJson is Map<String, dynamic>
          ? HomeServiceProviderModel.fromApiJson(serviceProviderJson)
          : null,
    );
  }
}
