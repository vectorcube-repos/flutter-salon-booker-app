import 'package:dio/dio.dart';
import 'package:salon_booker_app/core/services/auth/auth_session_notifier.dart';
import 'package:salon_booker_app/core/services/storage/secure_storage_service.dart';

/// Interceptor that automatically adds authentication tokens to requests
/// and handles 401 Unauthorized responses.
class AuthInterceptor extends Interceptor {
  final SecureStorageService _secureStorage;
  final AuthSessionNotifier? _sessionNotifier;

  AuthInterceptor(
    this._secureStorage, {
    AuthSessionNotifier? sessionNotifier,
  }) : _sessionNotifier = sessionNotifier;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.getAccessToken();

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    final requestPath = err.requestOptions.path;
    final hasAuthHeader =
        err.requestOptions.headers['Authorization'] != null;
    final isAuthEndpoint = _isAuthEndpoint(requestPath);

    if (hasAuthHeader && !isAuthEndpoint && statusCode == 401) {
      await _secureStorage.clearAuthData();
      _sessionNotifier?.notifyUnauthorized();
    }

    if (hasAuthHeader &&
        !isAuthEndpoint &&
        statusCode == 403 &&
        _isAccountDisabledResponse(err.response?.data)) {
      await _secureStorage.clearAuthData();
      _sessionNotifier?.notifyAccountDisabled();
    }

    return handler.next(err);
  }

  bool _isAccountDisabledResponse(dynamic data) {
    if (data is! Map<String, dynamic>) return false;

    final code = data['code']?.toString().toLowerCase();
    final reason = data['reason']?.toString().toLowerCase();
    final message = data['message']?.toString().toLowerCase();

    return code == 'account_disabled' ||
        reason == 'account_disabled' ||
        (message != null && message.contains('account disabled'));
  }

  /// Paths where 401 should not trigger global session clear (unauthenticated flows).
  bool _isAuthEndpoint(String path) {
    return path.endsWith('/login') ||
        path.endsWith('/auth/otp/request') ||
        path.endsWith('/auth/otp/verify');
  }
}
