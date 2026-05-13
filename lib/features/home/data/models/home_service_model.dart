import 'package:salon_booker_app/features/home/domain/entities/home_service.dart';

class HomeServiceModel extends HomeService {
  const HomeServiceModel({
    required super.id,
    required super.name,
    super.imageThumb,
  });

  factory HomeServiceModel.fromApiJson(Map<String, dynamic> json) {
    final idRaw = json['id'];
    if (idRaw == null) {
      throw const FormatException('Home service id is required');
    }

    final id = idRaw is int ? idRaw : int.tryParse(idRaw.toString());
    if (id == null) {
      throw const FormatException('Home service id must be a valid integer');
    }

    final imageThumbValue = (json['image'] ?? json['image_thumb'])
        ?.toString()
        .trim();

    return HomeServiceModel(
      id: id,
      name: json['name']?.toString() ?? '',
      imageThumb: imageThumbValue == null || imageThumbValue.isEmpty
          ? null
          : imageThumbValue,
    );
  }
}
