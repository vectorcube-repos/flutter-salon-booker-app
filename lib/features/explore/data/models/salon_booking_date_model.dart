import 'package:salon_booker_app/features/explore/domain/entities/salon_booking_date.dart';

class SalonBookingDateModel extends SalonBookingDate {
  const SalonBookingDateModel({
    required super.date,
    required super.label,
    required super.day,
    required super.dayNumber,
    required super.month,
    super.dayName,
    super.isToday,
    super.isClosed,
    super.openingTime,
    super.closingTime,
  });

  factory SalonBookingDateModel.fromApiJson(Map<String, dynamic> json) {
    return SalonBookingDateModel(
      date: json['date']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      day: json['day']?.toString() ?? '',
      dayNumber: json['day_number']?.toString() ?? '',
      month: json['month']?.toString() ?? '',
      dayName: json['day_name']?.toString(),
      isToday: json['is_today'] == true,
      isClosed: json['is_closed'] == true,
      openingTime: json['opening_time']?.toString(),
      closingTime: json['closing_time']?.toString(),
    );
  }
}
