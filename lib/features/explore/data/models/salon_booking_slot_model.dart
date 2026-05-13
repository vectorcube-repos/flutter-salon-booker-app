import 'package:salon_booker_app/features/explore/domain/entities/salon_booking_slot.dart';

class SalonBookingSlotModel extends SalonBookingSlot {
  const SalonBookingSlotModel({
    required super.start,
    required super.end,
    required super.label,
  });

  factory SalonBookingSlotModel.fromApiJson(Map<String, dynamic> json) {
    return SalonBookingSlotModel(
      start: json['start']?.toString() ?? '',
      end: json['end']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
    );
  }
}
