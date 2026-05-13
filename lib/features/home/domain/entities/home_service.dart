import 'package:equatable/equatable.dart';

class HomeService extends Equatable {
  final int id;
  final String name;
  final String? imageThumb;

  const HomeService({required this.id, required this.name, this.imageThumb});

  @override
  List<Object?> get props => [id, name, imageThumb];
}
