import 'package:salon_booker_app/features/authentication/domain/entities/user.dart';

class UserModel extends User {
  final String token;

  const UserModel({
    required super.id,
    required super.name,
    required super.phone,
    required this.token,
  });

  /// Parses the OTP verify API response where user has first_name/last_name instead of name.
  /// Uses defensive parsing for [id] and [phone] to tolerate string values from API.
  factory UserModel.fromVerifyOtpJson(Map<String, dynamic> json) {
    if (json['status'] != true ||
        json['data'] is! Map<String, dynamic>) {
      throw FormatException(
        'Invalid verify OTP response: ${json.toString()}',
      );
    }
    final data = json['data'] as Map<String, dynamic>;
    final user = data['user'] as Map<String, dynamic>;
    final token = data['token'] is String ? data['token'] as String : '';
    final id = _parseInt(user['id'], 0);
    final phone = (user['phone']?.toString() ?? '').trim();
    final first = user['first_name']?.toString().trim() ?? '';
    final last = user['last_name']?.toString().trim() ?? '';
    final name = '$first $last'.trim().isEmpty ? 'Guest' : '$first $last'.trim();
    if (id <= 0 || phone.isEmpty || token.isEmpty) {
      throw FormatException(
        'Invalid verify OTP response: missing or invalid user/token data',
      );
    }
    return UserModel(
      id: id,
      name: name,
      phone: phone,
      token: token,
    );
  }

  static int _parseInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  factory UserModel.fromLocalJson(Map<String, dynamic> json) {
    try {
      if (!json.containsKey('id') ||
          !json.containsKey('name') ||
          !json.containsKey('phone')) {
        throw const FormatException('Invalid local user data');
      }

      return UserModel(
        id: json['id'] as int,
        name: json['name'] as String,
        phone: json['phone'] as String,
        token: json['token'] as String? ?? '',
      );
    } catch (e) {
      throw FormatException('Failed to parse local user data: ${e.toString()}');
    }
  }

  /// Converts [UserModel] to JSON for local persistence.
  Map<String, dynamic> toLocalJson() {
    return {'id': id, 'name': name, 'phone': phone};
  }

  /// Converts [UserModel] to domain [User] entity.
  User toEntity() {
    return User(id: id, name: name, phone: phone);
  }

  @override
  List<Object?> get props => [id, name, phone, token];
}
