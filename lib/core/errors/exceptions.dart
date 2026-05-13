import 'package:equatable/equatable.dart';

class ServerException extends Equatable implements Exception {
  const ServerException({this.message, this.statusCode, this.errors});

  final String? message;
  final int? statusCode;
  final Map<String, List<String>>? errors;

  @override
  List<Object?> get props => [message, statusCode, errors];
}
