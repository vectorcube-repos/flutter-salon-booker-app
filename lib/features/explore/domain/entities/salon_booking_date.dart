import 'package:equatable/equatable.dart';

class SalonBookingDate extends Equatable {
  const SalonBookingDate({
    required this.date,
    required this.label,
    required this.day,
    required this.dayNumber,
    required this.month,
    this.dayName,
    this.isToday = false,
    this.isClosed = false,
    this.openingTime,
    this.closingTime,
  });

  final String date;
  final String label;
  final String day;
  final String dayNumber;
  final String month;
  final String? dayName;
  final bool isToday;
  final bool isClosed;
  final String? openingTime;
  final String? closingTime;

  @override
  List<Object?> get props => [
    date,
    label,
    day,
    dayNumber,
    month,
    dayName,
    isToday,
    isClosed,
    openingTime,
    closingTime,
  ];
}
