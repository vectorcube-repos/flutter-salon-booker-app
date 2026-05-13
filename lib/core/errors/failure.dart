import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure({
    this.message,
  });

  final String? message;
  
  @override
  List<Object?> get props => [message];
}


class ServerFailure extends Failure {
  
  const ServerFailure({
    super.message,
  });
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message,
  });
}


class ApiFailure extends Failure {
  const ApiFailure({
    super.message,
    this.statusCode,
    this.errors,
  });

  final int? statusCode;
  final Map<String, List<String>>? errors;

  /// Get all error messages as a flat list
  List<String> getAllErrors() {
    if (errors == null || errors!.isEmpty) return [message ?? ''];
    return errors!.values.expand((list) => list).toList();
  }

  /// Get error message for a specific field
  String? getFieldError(String field) {
    if (errors == null) return null;
    final fieldErrors = errors![field];
    return fieldErrors?.isNotEmpty == true ? fieldErrors!.first : null;
  }

  /// Get all error messages for a specific field
  List<String>? getFieldErrors(String field) {
    return errors?[field];
  }

  @override
  List<Object?> get props => [message, statusCode, errors];
}
