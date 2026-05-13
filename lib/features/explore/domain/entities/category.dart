import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final int id;
  final String name;
  final String icon;
  final int? productsCount;

  const Category({
    required this.id,
    required this.name,
    this.icon = '',
    this.productsCount,
  });

  @override
  List<Object?> get props => [id, name, icon, productsCount];
}
