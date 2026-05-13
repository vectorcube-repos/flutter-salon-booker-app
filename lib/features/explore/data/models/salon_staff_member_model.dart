import 'package:salon_booker_app/features/explore/domain/entities/salon_staff_member.dart';

class SalonStaffMemberModel extends SalonStaffMember {
  const SalonStaffMemberModel({
    required super.id,
    required super.name,
    super.role,
    super.experience,
    super.image,
    super.rating,
  });

  factory SalonStaffMemberModel.fromApiJson(Map<String, dynamic> json) {
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
      throw const FormatException('Salon staff id is required');
    }

    return SalonStaffMemberModel(
      id: id,
      name: json['display_name']?.toString() ?? json['name']?.toString() ?? '',
      role:
          json['role']?.toString() ??
          json['designation']?.toString() ??
          json['title']?.toString() ??
          json['bio']?.toString(),
      experience:
          json['experience']?.toString() ??
          json['experience_years']?.toString(),
      image: json['image']?.toString() ?? json['image_thumb']?.toString(),
      rating: asDouble(json['rating']),
    );
  }
}
