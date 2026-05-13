import 'package:salon_booker_app/features/home/domain/entities/home_service_provider.dart';

class HomeServiceProviderModel extends HomeServiceProvider {
  const HomeServiceProviderModel({
    required super.id,
    required super.displayName,
    super.imageThumb,
  });

  factory HomeServiceProviderModel.fromApiJson(Map<String, dynamic> json) {
    final idRaw = json['id'];
    if (idRaw == null) {
      throw const FormatException('Home service provider id is required');
    }

    final id = idRaw is int ? idRaw : int.tryParse(idRaw.toString());
    if (id == null) {
      throw const FormatException(
        'Home service provider id must be a valid integer',
      );
    }

    String? parseNullableString(Object? value) {
      final text = value?.toString().trim();
      if (text == null || text.isEmpty) return null;
      return text;
    }

    return HomeServiceProviderModel(
      id: id,
      displayName:
          json['display_name']?.toString() ?? json['name']?.toString() ?? '',
      imageThumb: parseNullableString(json['image_thumb'] ?? json['image']),
    );
  }
}
