import 'package:salon_booker_app/features/explore/domain/entities/category_list_item.dart';

class CategoryListItemModel extends CategoryListItem {
  const CategoryListItemModel({
    required super.id,
    required super.name,
    super.icon,
    required super.productsCount,
  });

  factory CategoryListItemModel.fromApiJson(Map<String, dynamic> json) {
    int parseInt(Object? value, {int fallback = 0}) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? fallback;
      return fallback;
    }

    final id = parseInt(json['id']);
    if (id == 0) {
      throw const FormatException('Category id is required');
    }

    final name = json['name'] is String ? json['name'] as String : '';
    final icon = json['icon'] is String ? json['icon'] as String : '';
    final productsCount = parseInt(json['products_count']);

    return CategoryListItemModel(
      id: id,
      name: name,
      icon: icon,
      productsCount: productsCount,
    );
  }
}
