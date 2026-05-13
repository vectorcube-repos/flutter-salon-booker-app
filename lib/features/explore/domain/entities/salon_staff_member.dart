import 'package:equatable/equatable.dart';

class SalonStaffMember extends Equatable {
  const SalonStaffMember({
    required this.id,
    required this.name,
    this.role,
    this.experience,
    this.image,
    this.rating,
  });

  final int id;
  final String name;
  final String? role;
  final String? experience;
  final String? image;
  final double? rating;

  @override
  List<Object?> get props => [id, name, role, experience, image, rating];
}
