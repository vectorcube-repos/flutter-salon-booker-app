import 'package:salon_booker_app/features/explore/domain/entities/explore_salon.dart';

class ExploreSalonModel extends ExploreSalon {
  const ExploreSalonModel({
    required super.id,
    required super.name,
    super.ownerId,
    super.description,
    super.phone,
    super.address,
    super.city,
    super.state,
    super.postalCode,
    super.latitude,
    super.longitude,
    super.status,
    super.image,
    super.isFavorite,
  });

  factory ExploreSalonModel.fromApiJson(Map<String, dynamic> json) {
    final idRaw = json['id'];
    if (idRaw == null) {
      throw const FormatException('Explore salon id is required');
    }

    final id = idRaw is int ? idRaw : int.tryParse(idRaw.toString());
    if (id == null) {
      throw const FormatException('Explore salon id must be a valid integer');
    }

    int? parseInt(Object? value) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '');
    }

    double? parseDouble(Object? value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '');
    }

    String? parseNullableString(Object? value) {
      final text = value?.toString().trim();
      if (text == null || text.isEmpty) return null;
      return text;
    }

    return ExploreSalonModel(
      id: id,
      ownerId: parseInt(json['owner_id']),
      name: json['name']?.toString() ?? '',
      description: parseNullableString(json['description']),
      phone: parseNullableString(json['phone']),
      address: parseNullableString(json['address']),
      city: parseNullableString(json['city']),
      state: parseNullableString(json['state']),
      postalCode: parseNullableString(json['postal_code']),
      latitude: parseDouble(json['latitude']),
      longitude: parseDouble(json['longitude']),
      status: parseNullableString(json['status']),
      image: parseNullableString(json['image']),
      isFavorite: json['is_favorite'] == true,
    );
  }
}
