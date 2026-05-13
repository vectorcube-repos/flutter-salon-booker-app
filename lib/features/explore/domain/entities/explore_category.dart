import 'package:equatable/equatable.dart';

class ExploreCategory extends Equatable {
  final int id;
  final String name;
  final String? image;

  const ExploreCategory({required this.id, required this.name, this.image});

  @override
  List<Object?> get props => [id, name, image];
}
