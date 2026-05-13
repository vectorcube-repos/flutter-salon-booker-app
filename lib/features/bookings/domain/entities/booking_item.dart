import 'package:equatable/equatable.dart';

class BookingItem extends Equatable {
  final int id;
  final String? salonImage;
  final String salonName;
  final String serviceName;
  final String staffName;
  final String timeLabel;
  final String? slotStart;
  final String? status;
  final String statusLabel;

  const BookingItem({
    required this.id,
    required this.salonName,
    required this.serviceName,
    required this.staffName,
    required this.timeLabel,
    required this.statusLabel,
    this.salonImage,
    this.slotStart,
    this.status,
  });

  @override
  List<Object?> get props => [
    id,
    salonImage,
    salonName,
    serviceName,
    staffName,
    timeLabel,
    slotStart,
    status,
    statusLabel,
  ];
}
