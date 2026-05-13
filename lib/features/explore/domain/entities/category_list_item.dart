import 'package:equatable/equatable.dart';

class CategoryListItem extends Equatable {
  final int id;
  final String name;
  final String icon;
  final int productsCount;

  const CategoryListItem({
    required this.id,
    required this.name,
    this.icon = '',
    required this.productsCount,
  });

  @override
  List<Object?> get props => [id, name, icon, productsCount];
}
