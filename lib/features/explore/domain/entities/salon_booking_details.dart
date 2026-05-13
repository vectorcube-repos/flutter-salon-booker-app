import 'package:equatable/equatable.dart';
import 'package:salon_booker_app/features/explore/domain/entities/salon_booking_date.dart';
import 'package:salon_booker_app/features/explore/domain/entities/salon_booking_service.dart';
import 'package:salon_booker_app/features/explore/domain/entities/salon_booking_slot.dart';
import 'package:salon_booker_app/features/explore/domain/entities/salon_staff_member.dart';

class SalonBookingDetails extends Equatable {
  const SalonBookingDetails({
    required this.id,
    required this.name,
    this.description,
    this.address,
    this.city,
    this.state,
    this.status,
    this.image,
    this.services = const [],
    this.staffMembers = const [],
    this.dates = const [],
    this.slots = const [],
    this.selectedStaffId,
    this.selectedDate,
  });

  final int id;
  final String name;
  final String? description;
  final String? address;
  final String? city;
  final String? state;
  final String? status;
  final String? image;
  final List<SalonBookingService> services;
  final List<SalonStaffMember> staffMembers;
  final List<SalonBookingDate> dates;
  final List<SalonBookingSlot> slots;
  final int? selectedStaffId;
  final String? selectedDate;

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    address,
    city,
    state,
    status,
    image,
    services,
    staffMembers,
    dates,
    slots,
    selectedStaffId,
    selectedDate,
  ];
}
