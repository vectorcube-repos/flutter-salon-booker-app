import 'package:equatable/equatable.dart';

class HomeServiceProvider extends Equatable {
  final int id;
  final String displayName;
  final String? imageThumb;

  const HomeServiceProvider({
    required this.id,
    required this.displayName,
    this.imageThumb,
  });

  @override
  List<Object?> get props => [id, displayName, imageThumb];
}
