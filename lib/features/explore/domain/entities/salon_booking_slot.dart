import 'package:equatable/equatable.dart';

class SalonBookingSlot extends Equatable {
  const SalonBookingSlot({
    required this.start,
    required this.end,
    required this.label,
  });

  final String start;
  final String end;
  final String label;

  @override
  List<Object?> get props => [start, end, label];
}
