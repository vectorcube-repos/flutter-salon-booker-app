import 'package:salon_booker_app/features/explore/domain/entities/color.dart';

class ColorModel extends ProductColor {
  const ColorModel({
    required super.id,
    required super.name,
    super.colorCode,
  });

  factory ColorModel.fromApiJson(Map<String, dynamic> json) {
    final idRaw = json['id'];
    if (idRaw == null) {
      throw const FormatException('Color id is required');
    }
    final id = idRaw is int
        ? idRaw
        : int.tryParse(idRaw.toString());
    if (id == null) {
      throw const FormatException('Color id must be a valid integer');
    }

    final name = json['name'] is String ? json['name'] as String : '';
    final colorCode = json['color_code'] is String
        ? json['color_code'] as String
        : json['colorCode'] is String
            ? json['colorCode'] as String
            : '';

    return ColorModel(
      id: id,
      name: name,
      colorCode: colorCode,
    );
  }
}
