import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:salon_booker_app/core/services/storage/secure_storage_service.dart';

class DioInterceptor extends Interceptor {
  final SecureStorageService _secureStorage;

  DioInterceptor(this._secureStorage);
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final crashlytics = FirebaseCrashlytics.instance;

    // Do not log anything if crashlytics is disabled or app is in debug
    if (kDebugMode || !(crashlytics.isCrashlyticsCollectionEnabled)) {
      return handler.next(err);
    }

    final request = err.requestOptions;

    try {
      // Categorize the error
      final errorCategory = _categorizeError(err);
      final statusCode = err.response?.statusCode ?? 0;

      // Get authenticated user ID if available
      final userId = await _secureStorage.getUserId();

      // Set custom keys for filtering in Firebase Console
      await crashlytics.setCustomKey('error_category', errorCategory);
      await crashlytics.setCustomKey('http_method', request.method);
      await crashlytics.setCustomKey('endpoint', request.path);
      await crashlytics.setCustomKey('status_code', statusCode);
      await crashlytics.setCustomKey('error_type', err.type.name);
      
      // Set user ID if authenticated
      if (userId != null) {
        await crashlytics.setCustomKey('user_id', userId);
        // Also set as user identifier for better tracking
        await crashlytics.setUserIdentifier(userId.toString());
      }

      // Log error details with structure
      await crashlytics.log('=' * 50);
      await crashlytics.log('API ERROR: $errorCategory');
      if (userId != null) {
        await crashlytics.log('User ID: $userId');
      }
      await crashlytics.log('=' * 50);
      
      // Request details
      await crashlytics.log('REQUEST:');
      await crashlytics.log('  Method: ${request.method}');
      await crashlytics.log('  URL: ${request.uri}');
      await crashlytics.log('  Headers: ${_sanitizeHeaders(request.headers)}');
      await crashlytics.log('  Body: ${_sanitize(request.data)}');

      // Response details
      if (err.response != null) {
        await crashlytics.log('RESPONSE:');
        await crashlytics.log('  Status Code: $statusCode');
        await crashlytics.log('  Headers: ${_sanitizeHeaders(err.response!.headers.map)}');
        await crashlytics.log('  Body: ${_sanitize(err.response?.data)}');
        
        // Extract error message if available
        final errorMessage = _extractErrorMessage(err.response?.data);
        if (errorMessage != null) {
          await crashlytics.log('  Error Message: $errorMessage');
        }
      } else {
        await crashlytics.log('RESPONSE: No response (${err.type.name})');
      }

      await crashlytics.log('=' * 50);

      // Record the error with detailed reason
      final userContext = userId != null ? ' (User: $userId)' : '';
      await crashlytics.recordError(
        err,
        err.stackTrace,
        fatal: false,
        reason: '[$errorCategory] ${request.method} ${request.path} - Status: $statusCode$userContext',
      );
    } catch (_) {
      // NEVER allow interceptor to break calls
    }

    return handler.next(err);
  }

  /// Categorizes the error type for better debugging
  String _categorizeError(DioException err) {
    if (err.response != null) {
      final status = err.response!.statusCode ?? 0;
      if (status >= 400 && status < 500) {
        return 'Client Error';
      }
      if (status >= 500) {
        return 'Server Error';
      }
    }

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Timeout Error';
      case DioExceptionType.connectionError:
        return 'Network Error';
      case DioExceptionType.badCertificate:
        return 'Certificate Error';
      case DioExceptionType.cancel:
        return 'Request Cancelled';
      default:
        return 'Unknown Error';
    }
  }

  /// Extracts error message from response data
  String? _extractErrorMessage(dynamic data) {
    if (data == null) return null;

    if (data is Map<String, dynamic>) {
      // Try common error message keys
      if (data.containsKey('message')) {
        return data['message']?.toString();
      }
      if (data.containsKey('error')) {
        return data['error']?.toString();
      }
      if (data.containsKey('detail')) {
        return data['detail']?.toString();
      }
    }

    return null;
  }

  /// Recursively sanitizes sensitive data from maps
  String _sanitize(dynamic data) {
    if (data == null) return 'null';

    if (data is Map) {
      return _sanitizeMap(data).toString();
    }

    if (data is List) {
      return data.map((item) => _sanitize(item)).toList().toString();
    }

    if (data is String) {
      final lower = data.toLowerCase();
      if (lower.contains('password') ||
          lower.contains('token') ||
          lower.contains('authorization') ||
          lower.contains('secret')) {
        return '[REDACTED]';
      }
    }

    return data.toString();
  }

  /// Recursively sanitizes a map, handling nested structures
  Map<String, dynamic> _sanitizeMap(Map<dynamic, dynamic> data) {
    final sanitized = <String, dynamic>{};

    // Sensitive field patterns to remove
    final sensitivePatterns = [
      'password',
      'token',
      'access_token',
      'refresh_token',
      'authorization',
      'secret',
      'api_key',
      'apikey',
      'private_key',
      'client_secret',
      'credit_card',
      'card_number',
      'cvv',
      'ssn',
      'pin',
    ];

    for (final entry in data.entries) {
      final key = entry.key.toString().toLowerCase();
      final value = entry.value;

      // Check if key matches any sensitive pattern
      final isSensitive = sensitivePatterns.any((pattern) => key.contains(pattern));

      if (isSensitive) {
        sanitized[entry.key.toString()] = '[REDACTED]';
      } else if (value is Map) {
        // Recursively sanitize nested maps
        sanitized[entry.key.toString()] = _sanitizeMap(value);
      } else if (value is List) {
        // Sanitize lists
        sanitized[entry.key.toString()] = value.map((item) {
          if (item is Map) {
            return _sanitizeMap(item);
          }
          return item;
        }).toList();
      } else {
        sanitized[entry.key.toString()] = value;
      }
    }

    return sanitized;
  }

  /// Sanitizes HTTP headers
  String _sanitizeHeaders(Map<String, dynamic> headers) {
    final sanitized = Map<String, dynamic>.from(headers);

    // Remove sensitive headers
    final sensitiveHeaders = [
      'Authorization',
      'authorization',
      'Cookie',
      'cookie',
      'Set-Cookie',
      'set-cookie',
      'X-Auth-Token',
      'x-auth-token',
      'X-API-Key',
      'x-api-key',
    ];

    for (final header in sensitiveHeaders) {
      sanitized.remove(header);
    }

    return sanitized.toString();
  }
}
