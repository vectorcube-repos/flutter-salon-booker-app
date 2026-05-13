import 'package:equatable/equatable.dart';

class ProductMaterial extends Equatable {
  final int id;
  final String name;

  const ProductMaterial({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}
