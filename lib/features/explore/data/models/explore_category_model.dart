import 'package:salon_booker_app/features/explore/domain/entities/explore_category.dart';

class ExploreCategoryModel extends ExploreCategory {
  const ExploreCategoryModel({
    required super.id,
    required super.name,
    super.image,
  });

  factory ExploreCategoryModel.fromApiJson(Map<String, dynamic> json) {
    final idRaw = json['id'];
    if (idRaw == null) {
      throw const FormatException('Explore category id is required');
    }

    final id = idRaw is int ? idRaw : int.tryParse(idRaw.toString());
    if (id == null) {
      throw const FormatException(
        'Explore category id must be a valid integer',
      );
    }

    final imageValue = json['image']?.toString().trim();

    return ExploreCategoryModel(
      id: id,
      name: json['name']?.toString() ?? '',
      image: imageValue == null || imageValue.isEmpty ? null : imageValue,
    );
  }
}
