import 'package:salon_booker_app/features/explore/data/models/category_model.dart';
import 'package:salon_booker_app/features/explore/data/models/color_model.dart';
import 'package:salon_booker_app/features/explore/data/models/material_model.dart';
import 'package:salon_booker_app/features/explore/domain/entities/product_details.dart';

class ProductDetailsModel extends ProductDetails {
  const ProductDetailsModel({
    required super.id,
    required super.name,
    required super.price,
    required super.description,
    required super.photo,
    required super.isFavorite,
    super.categories,
    super.materials,
    super.colors,
  });

  factory ProductDetailsModel.fromApiJson(Map<String, dynamic> json) {
    int? asInt(Object? value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '');
    }

    final id = asInt(json['id']);
    if (id == null) {
      throw const FormatException('Product details id is required');
    }

    final priceRaw = json['price'];
    final parsedPrice = priceRaw is int
        ? priceRaw.toDouble()
        : priceRaw is num
            ? priceRaw.toDouble()
            : (double.tryParse(priceRaw?.toString() ?? '') ?? 0.0);

    List<T> parseList<T>(
      Object? raw,
      T Function(Map<String, dynamic>) parser,
    ) {
      if (raw is! List) return const [];
      return raw.whereType<Map<String, dynamic>>().map(parser).toList();
    }

    return ProductDetailsModel(
      id: id,
      name: json['name'] is String ? json['name'] as String : '',
      price: parsedPrice.isNaN ? 0.0 : parsedPrice,
      description:
          json['description'] is String ? json['description'] as String : '',
      photo: json['photo'] is String ? json['photo'] as String : '',
      isFavorite: json['is_favorite'] == true,
      categories: parseList(json['categories'], CategoryModel.fromApiJson),
      materials: parseList(json['materials'], MaterialModel.fromApiJson),
      colors: parseList(json['colors'], ColorModel.fromApiJson),
    );
  }
}
