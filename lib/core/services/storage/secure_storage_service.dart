import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class SecureStorageService {
  const SecureStorageService();

  /// Initialize the storage service. Must be called before using any other methods.
  Future<void> init();

  /// Writes a value to secure storage.
  /// Throws an exception if the write operation fails.
  Future<void> write(String key, String value);

  /// Reads a value from secure storage.
  /// Returns `null` if the key doesn't exist or if an error occurs.
  /// Errors are logged but not thrown.
  Future<String?> read(String key);

  /// Deletes a specific key from secure storage.
  Future<void> delete(String key);

  /// Clears all data from secure storage.
  Future<void> clearAll();

  // Token Management
  Future<void> saveAccessToken(String token);
  Future<String?> getAccessToken();
  Future<void> deleteAccessToken();

  Future<void> saveRefreshToken(String token);
  Future<String?> getRefreshToken();
  Future<void> deleteRefreshToken();

  // User Management
  Future<void> saveUser(String userJson);
  Future<String?> getUser();
  Future<void> deleteUser();

  Future<void> saveUserId(int userId);
  Future<int?> getUserId();
  Future<void> deleteUserId();

  // FCM Token Management
  Future<void> saveFcmToken(String token);
  Future<String?> getFcmToken();
  Future<void> deleteFcmToken();

  // Helper Methods
  /// Check if user is authenticated (has access token)
  Future<bool> isAuthenticated();

  /// Clear all authentication data (tokens + user)
  Future<void> clearAuthData();

  /// Save complete auth session (atomic operation)
  Future<void> saveAuthSession({
    required String accessToken,
    required String refreshToken,
    required String userJson,
    required int userId,
  });
}

class SecureStorageServiceImpl implements SecureStorageService {
  static const _logTag = 'SecureStorage';

  // ✅ Centralized keys
  static const _kAccessToken = 'access_token';
  static const _kRefreshToken = 'refresh_token';
  static const _kUser = 'user';
  static const _kUserId = 'user_id';
  static const _kFcmToken = 'fcm_token';
  static const _kFirstRun = 'is_first_run';

  final FlutterSecureStorage _storage;
  final SharedPreferences _prefs;
  bool _initialized = false;

  SecureStorageServiceImpl(this._storage, this._prefs);

  /// ✅ Call at app startup
  @override
  Future<void> init() async {
    if (_initialized) return;

    final isFirstRun = _prefs.getBool(_kFirstRun) ?? true;

    if (isFirstRun) {
      _log('First run detected, clearing secure storage.');
      await _safeClear();
      await _prefs.setBool(_kFirstRun, false);
    }

    _initialized = true;
  }

  /// Ensures that init() has been called before using the service
  void _ensureInitialized() {
    assert(
      _initialized,
      'SecureStorageService.init() must be called before using the service',
    );
  }

  // ---------------------------------------------------------------------------
  // Core Safe Operations
  // ---------------------------------------------------------------------------

  @override
  Future<String?> read(String key) async {
    _ensureInitialized();
    try {
      return await _storage.read(key: key);
    } on PlatformException catch (e) {
      if (_isBadDecrypt(e)) {
        _log('BAD_DECRYPT for key: $key. Deleting corrupted key.');
        await _safeDelete(key);
      } else {
        _logError('PlatformException during read for $key', e);
      }
      return null;
    } catch (e, s) {
      _logError('Unknown error during read for $key', e, s);
      return null;
    }
  }

  @override
  Future<void> write(String key, String value) async {
    _ensureInitialized();
    try {
      await _storage.write(key: key, value: value);
    } catch (e, s) {
      _logError('Write failed for key $key', e, s);
      rethrow;
    }
  }

  @override
  Future<void> delete(String key) async {
    _ensureInitialized();
    await _safeDelete(key);
  }

  @override
  Future<void> clearAll() async {
    _ensureInitialized();
    await _safeClear();
  }

  // ---------------------------------------------------------------------------
  // Token Management
  // ---------------------------------------------------------------------------

  @override
  Future<void> saveAccessToken(String token) async {
    await write(_kAccessToken, token);
  }

  @override
  Future<String?> getAccessToken() async {
    return read(_kAccessToken);
  }

  @override
  Future<void> deleteAccessToken() async {
    await delete(_kAccessToken);
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    await write(_kRefreshToken, token);
  }

  @override
  Future<String?> getRefreshToken() async {
    return read(_kRefreshToken);
  }

  @override
  Future<void> deleteRefreshToken() async {
    await delete(_kRefreshToken);
  }

  // ---------------------------------------------------------------------------
  // User
  // ---------------------------------------------------------------------------

  @override
  Future<void> saveUser(String userJson) async {
    await write(_kUser, userJson);
  }

  @override
  Future<String?> getUser() async {
    return read(_kUser);
  }

  @override
  Future<void> deleteUser() async {
    await delete(_kUser);
  }

  @override
  Future<void> saveUserId(int userId) async {
    await write(_kUserId, userId.toString());
  }

  @override
  Future<int?> getUserId() async {
    final userIdStr = await read(_kUserId);
    if (userIdStr == null) return null;
    return int.tryParse(userIdStr);
  }

  @override
  Future<void> deleteUserId() async {
    await delete(_kUserId);
  }

  // ---------------------------------------------------------------------------
  // FCM Token
  // ---------------------------------------------------------------------------

  @override
  Future<void> saveFcmToken(String token) async {
    await write(_kFcmToken, token);
  }

  @override
  Future<String?> getFcmToken() async {
    return read(_kFcmToken);
  }

  @override
  Future<void> deleteFcmToken() async {
    await delete(_kFcmToken);
  }

  // ---------------------------------------------------------------------------
  // Helper Methods
  // ---------------------------------------------------------------------------

  @override
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> clearAuthData() async {
    await Future.wait([
      deleteAccessToken(),
      deleteRefreshToken(),
      deleteUser(),
      deleteUserId(),
    ]);
  }

  @override
  Future<void> saveAuthSession({
    required String accessToken,
    required String refreshToken,
    required String userJson,
    required int userId,
  }) async {
    await Future.wait([
      saveAccessToken(accessToken),
      saveRefreshToken(refreshToken),
      saveUser(userJson),
      saveUserId(userId),
    ]);
  }

  // ---------------------------------------------------------------------------
  // Internal Helpers
  // ---------------------------------------------------------------------------

  bool _isBadDecrypt(PlatformException e) {
    return e.message?.toUpperCase().contains('BAD_DECRYPT') == true;
  }

  Future<void> _safeDelete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e, s) {
      _logError('Delete failed for key $key', e, s);
    }
  }

  Future<void> _safeClear() async {
    try {
      await _storage.deleteAll();
    } catch (e, s) {
      _logError('DeleteAll failed', e, s);
    }
  }

  void _log(String message) {
    log(message, name: _logTag);
  }

  void _logError(String message, Object error, [StackTrace? stack]) {
    log(message, name: _logTag, error: error, stackTrace: stack);
  }
}
