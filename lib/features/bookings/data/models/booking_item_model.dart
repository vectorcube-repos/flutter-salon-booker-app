import 'package:salon_booker_app/features/bookings/domain/entities/booking_item.dart';

class BookingItemModel extends BookingItem {
  const BookingItemModel({
    required super.id,
    required super.salonName,
    required super.serviceName,
    required super.staffName,
    required super.timeLabel,
    required super.statusLabel,
    super.salonImage,
    super.slotStart,
    super.status,
  });

  factory BookingItemModel.fromApiJson(Map<String, dynamic> json) {
    int parseInt(Object? value, {int fallback = 0}) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? fallback;
    }

    String? parseNullableString(Object? value) {
      final text = value?.toString().trim();
      if (text == null || text.isEmpty) return null;
      return text;
    }

    return BookingItemModel(
      id: parseInt(json['id']),
      salonImage: parseNullableString(json['salon_image']),
      salonName: json['salon_name']?.toString() ?? '',
      serviceName: json['service_name']?.toString() ?? '',
      staffName: json['staff_name']?.toString() ?? '',
      timeLabel: json['time']?.toString() ?? '',
      slotStart: parseNullableString(json['slot_start']),
      status: parseNullableString(json['status']),
      statusLabel:
          json['status_label']?.toString() ??
          json['status']?.toString() ??
          'Unknown',
    );
  }
}
