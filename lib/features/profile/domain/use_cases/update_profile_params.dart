import 'package:equatable/equatable.dart';

class UpdateProfileParams extends Equatable {
  final String name;
  final String phone;

  const UpdateProfileParams({
    required this.name,
    required this.phone,
  });

  @override
  List<Object?> get props => [name, phone];
}
