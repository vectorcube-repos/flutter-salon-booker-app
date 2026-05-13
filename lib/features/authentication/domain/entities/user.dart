import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String phone;
  final String name;

  const User({
    required this.id,
    required this.phone,
    required this.name,
  });

  @override
  List<Object?> get props => [id, phone, name];
}