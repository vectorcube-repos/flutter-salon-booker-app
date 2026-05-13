import 'package:salon_booker_app/features/profile/domain/entities/profile.dart';

class ProfileModel extends Profile {
  const ProfileModel({
    required super.id,
    required super.name,
    required super.phone,
  });

  factory ProfileModel.fromApiJson(Map<String, dynamic> json) {
    final idRaw = json['id'];
    final parsedId = idRaw is int ? idRaw : int.tryParse(idRaw?.toString() ?? '') ?? 0;

    return ProfileModel(
      id: parsedId,
      name: json['name'] is String ? json['name'] as String : '',
      phone: json['phone'] is String ? json['phone'] as String : '',
    );
  }
}
