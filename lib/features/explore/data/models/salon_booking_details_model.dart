import 'package:salon_booker_app/features/explore/data/models/salon_booking_date_model.dart';
import 'package:salon_booker_app/features/explore/data/models/salon_booking_service_model.dart';
import 'package:salon_booker_app/features/explore/data/models/salon_booking_slot_model.dart';
import 'package:salon_booker_app/features/explore/data/models/salon_staff_member_model.dart';
import 'package:salon_booker_app/features/explore/domain/entities/salon_booking_details.dart';

class SalonBookingDetailsModel extends SalonBookingDetails {
  const SalonBookingDetailsModel({
    required super.id,
    required super.name,
    super.description,
    super.address,
    super.city,
    super.state,
    super.status,
    super.image,
    super.services,
    super.staffMembers,
    super.dates,
    super.slots,
    super.selectedStaffId,
    super.selectedDate,
  });

  factory SalonBookingDetailsModel.fromApiJson(Map<String, dynamic> json) {
    int? asInt(Object? value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '');
    }

    Map<String, dynamic>? asMap(Object? value) {
      if (value is Map<String, dynamic>) return value;
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
      return null;
    }

    List<Map<String, dynamic>> asListOfMaps(Object? value) {
      if (value is List) {
        return value
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
      if (value is Map) {
        final map = Map<String, dynamic>.from(value);
        final data = map['data'];
        if (data is List) {
          return data
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        }
      }
      return const [];
    }

    final payload = asMap(json['data']) ?? json;
    final salon =
        asMap(payload['salon']) ??
        asMap(payload['saloon']) ??
        asMap(payload['product']) ??
        payload;

    final id = asInt(salon['id']);
    if (id == null) {
      throw const FormatException('Salon details id is required');
    }

    return SalonBookingDetailsModel(
      id: id,
      name: salon['name']?.toString() ?? '',
      description: salon['description']?.toString(),
      address: salon['address']?.toString(),
      city: salon['city']?.toString(),
      state: salon['state']?.toString(),
      status: salon['status']?.toString(),
      image:
          salon['image']?.toString() ??
          salon['photo']?.toString() ??
          salon['image_thumb']?.toString(),
      services: asListOfMaps(
        payload['services'] ?? salon['services'],
      ).map(SalonBookingServiceModel.fromApiJson).toList(),
      staffMembers: asListOfMaps(
        payload['staff'] ??
            payload['staffs'] ??
            payload['staff_members'] ??
            salon['staff'] ??
            salon['staffs'] ??
            salon['staff_members'],
      ).map(SalonStaffMemberModel.fromApiJson).toList(),
      dates: asListOfMaps(
        payload['dates'] ?? salon['dates'],
      ).map(SalonBookingDateModel.fromApiJson).toList(),
      slots: asListOfMaps(
        payload['slots'] ?? salon['slots'],
      ).map(SalonBookingSlotModel.fromApiJson).toList(),
      selectedStaffId: asInt(
        payload['selected_staff_id'] ?? salon['selected_staff_id'],
      ),
      selectedDate:
          payload['selected_date']?.toString() ??
          salon['selected_date']?.toString(),
    );
  }
}
