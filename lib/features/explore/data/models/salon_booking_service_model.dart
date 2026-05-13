import 'package:salon_booker_app/features/explore/domain/entities/salon_booking_service.dart';

class SalonBookingServiceModel extends SalonBookingService {
  const SalonBookingServiceModel({
    required super.id,
    required super.name,
    super.durationMinutes,
    super.price,
    super.image,
  });

  factory SalonBookingServiceModel.fromApiJson(Map<String, dynamic> json) {
    int? asInt(Object? value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '');
    }

    double? asDouble(Object? value) {
      if (value is double) return value;
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '');
    }

    final id = asInt(json['id']);
    if (id == null) {
      throw const FormatException('Salon booking service id is required');
    }

    return SalonBookingServiceModel(
      id: id,
      name: json['name']?.toString() ?? '',
      durationMinutes:
          asInt(json['duration_minutes']) ??
          asInt(json['duration']) ??
          asInt(json['duration_in_minutes']),
      price: asDouble(json['price']) ?? asDouble(json['rate']),
      image: json['image']?.toString() ?? json['image_thumb']?.toString(),
    );
  }
}
