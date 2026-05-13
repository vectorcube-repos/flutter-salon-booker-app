import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final int id;
  final String name;
  final String phone;

  const Profile({
    required this.id,
    required this.name,
    required this.phone,
  });

  @override
  List<Object?> get props => [id, name, phone];
}
