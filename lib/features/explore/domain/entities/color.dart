import 'package:equatable/equatable.dart';

class ProductColor extends Equatable {
  final int id;
  final String name;
  final String colorCode;

  const ProductColor({
    required this.id,
    required this.name,
    this.colorCode = '',
  });

  @override
  List<Object?> get props => [id, name, colorCode];
}
