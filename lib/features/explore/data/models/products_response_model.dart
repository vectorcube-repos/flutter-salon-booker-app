import 'package:salon_booker_app/features/explore/data/models/category_model.dart';
import 'package:salon_booker_app/features/explore/data/models/color_model.dart';
import 'package:salon_booker_app/features/explore/data/models/material_model.dart';
import 'package:salon_booker_app/features/explore/data/models/product_model.dart';

class ProductsResponseModel {
  final List<ProductModel> products;
  final List<CategoryModel> categories;
  final List<ColorModel> colors;
  final List<MaterialModel> materials;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;

  ProductsResponseModel({
    required this.products,
    this.categories = const [],
    this.colors = const [],
    this.materials = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
    this.perPage = 0,
  });

  factory ProductsResponseModel.fromApiJson(Map<String, dynamic> json) {
    final products = _parseList(json, 'products', ProductModel.fromApiJson);
    final categories = _parseList(json, 'categories', CategoryModel.fromApiJson);
    final colors = _parseList(json, 'colors', ColorModel.fromApiJson);
    final materials = _parseList(json, 'materials', MaterialModel.fromApiJson);
    final meta = _parseMeta(json, 'products');

    return ProductsResponseModel(
      products: products,
      categories: categories,
      colors: colors,
      materials: materials,
      currentPage: meta.currentPage,
      lastPage: meta.lastPage,
      total: meta.total,
      perPage: meta.perPage,
    );
  }

  static List<T> _parseList<T>(
    Map<String, dynamic> json,
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final section = json[key];
    final data = section is List
        ? section
        : (section is Map ? section['data'] : null);
    if (data is! List) return [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(fromJson)
        .toList();
  }

  static ({
    int currentPage,
    int lastPage,
    int total,
    int perPage,
  }) _parseMeta(Map<String, dynamic> json, String key) {
    final section = json[key];
    if (section is! Map) {
      return (currentPage: 1, lastPage: 1, total: 0, perPage: 0);
    }
    final meta = section['meta'];
    if (meta is! Map) {
      return (currentPage: 1, lastPage: 1, total: 0, perPage: 0);
    }

    int asInt(Object? value, int fallback) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? fallback;
      return fallback;
    }

    final currentPage = asInt(meta['current_page'], 1);
    final lastPage = asInt(meta['last_page'], currentPage);
    final total = asInt(meta['total'], 0);
    final perPage = asInt(meta['per_page'], 0);
    return (
      currentPage: currentPage,
      lastPage: lastPage,
      total: total,
      perPage: perPage,
    );
  }
}
