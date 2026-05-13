import 'package:salon_booker_app/features/salon_favorites/domain/entities/favorite_salon.dart';

class FavoriteSalonModel extends FavoriteSalon {
  const FavoriteSalonModel({
    required super.id,
    required super.name,
    super.image,
    super.address,
    super.city,
    super.state,
    super.status,
    super.isFavorite,
  });

  factory FavoriteSalonModel.fromApiJson(Map<String, dynamic> json) {
    int? parseInt(Object? value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '');
    }

    String? parseNullableString(Object? value) {
      final text = value?.toString().trim();
      if (text == null || text.isEmpty) return null;
      return text;
    }

    final source = json['salon'] is Map
        ? Map<String, dynamic>.from(json['salon'] as Map)
        : json;

    final id = parseInt(source['id']);
    if (id == null) {
      throw const FormatException('Favorite salon id is required');
    }

    return FavoriteSalonModel(
      id: id,
      name: source['name']?.toString() ?? '',
      image: parseNullableString(source['image'] ?? source['image_thumb']),
      address: parseNullableString(source['address']),
      city: parseNullableString(source['city']),
      state: parseNullableString(source['state']),
      status: parseNullableString(source['status']),
      isFavorite: true,
    );
  }
}
