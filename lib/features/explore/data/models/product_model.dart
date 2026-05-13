import 'package:salon_booker_app/core/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.price,
    required super.photo,
    required super.isFavorite,
  });

  factory ProductModel.fromApiJson(Map<String, dynamic> json) {
    final idRaw = json['id'];
    if (idRaw == null) {
      throw const FormatException('Product id is required');
    }
    final id = idRaw is int
        ? idRaw
        : int.tryParse(idRaw.toString());
    if (id == null) {
      throw const FormatException('Product id must be a valid integer');
    }

    final name = json['name'] is String ? json['name'] as String : '';

    final priceRaw = json['price'];
    final price = priceRaw is int
        ? priceRaw.toDouble()
        : priceRaw is num
            ? priceRaw.toDouble()
            : (double.tryParse(priceRaw?.toString() ?? '') ?? 0.0);

    final photo =
        json['photo'] is String ? json['photo'] as String : '';


    return ProductModel(
      id: id,
      name: name,
      price: price.isNaN ? 0.0 : price,
      photo: photo,
      isFavorite: json['is_favorite'] == true
    );
  }
}