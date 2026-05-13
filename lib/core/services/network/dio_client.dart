import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fpdart/fpdart.dart';
import 'package:salon_booker_app/core/errors/failure.dart';
import 'package:salon_booker_app/core/services/auth/auth_session_notifier.dart';
import 'package:salon_booker_app/core/services/network/interceptors/dio_interceptor.dart';
import 'package:salon_booker_app/core/services/storage/secure_storage_service.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'interceptors/auth_interceptor.dart';

class DioClient {
  final SecureStorageService _secureStorage;
  final AuthSessionNotifier? _sessionNotifier;

  late final Dio _dio;

  DioClient(
    this._secureStorage, {
    AuthSessionNotifier? sessionNotifier,
    Duration connectTimeout = const Duration(seconds: 30),
    Duration receiveTimeout = const Duration(seconds: 30),
    Duration sendTimeout = const Duration(seconds: 30),
  }) : _sessionNotifier = sessionNotifier {
    _dio = _createDio(
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
    );
  }

  Dio get dio => _dio;

  Dio _createDio({
    required Duration connectTimeout,
    required Duration receiveTimeout,
    required Duration sendTimeout,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000/api',
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // In debug only: allow self-signed / untrusted HTTPS certificates (e.g. local/staging).
    // Never enable this in production.
    if (kDebugMode) {
      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.badCertificateCallback = (_, _, _) => true;
          return client;
        },
      );
    }

    dio.interceptors.add(
      AuthInterceptor(_secureStorage, sessionNotifier: _sessionNotifier),
    );

    dio.interceptors.add(DioInterceptor(_secureStorage));

    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
        ),
      );
    }

    return dio;
  }

  // ----------------------------------------------------------
  // Unified Private Request Handler
  // ----------------------------------------------------------
  Future<Either<Failure, T>> _request<T>({
    required Future<Response> Function() sendRequest,
    required T Function(dynamic data) parser,
  }) async {
    try {
      final response = await sendRequest();
      return Right(parser(response.data));
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      final message = e is FormatException
          ? e.message
          : (e.toString().isNotEmpty ? e.toString() : 'An unexpected error occurred.');
      return Left(ServerFailure(message: message));
    }
  }

  // ----------------------------------------------------------
  // Public HTTP Methods
  // ----------------------------------------------------------

  Future<Either<Failure, T>> get<T>(
    String path, {
    required T Function(dynamic data) parser,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _request(
      sendRequest: () =>
          _dio.get(path, queryParameters: queryParameters, options: options),
      parser: parser,
    );
  }

  Future<Either<Failure, T>> post<T>(
    String path, {
    required T Function(dynamic data) parser,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _request(
      sendRequest: () => _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
      parser: parser,
    );
  }

  Future<Either<Failure, T>> put<T>(
    String path, {
    required T Function(dynamic data) parser,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _request(
      sendRequest: () => _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
      parser: parser,
    );
  }

  Future<Either<Failure, T>> patch<T>(
    String path, {
    required T Function(dynamic data) parser,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _request(
      sendRequest: () => _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
      parser: parser,
    );
  }

  Future<Either<Failure, T>> delete<T>(
    String path, {
    required T Function(dynamic data) parser,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _request(
      sendRequest: () => _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
      parser: parser,
    );
  }

  // ----------------------------------------------------------
  // Error Handling
  // ----------------------------------------------------------
  Failure _handleDioException(DioException e) {
    // No response = network issues
    if (e.response == null) {
      return NetworkFailure(message: _getNetworkErrorMessage(e));
    }

    final statusCode = e.response?.statusCode ?? 0;
    final data = e.response?.data;

    final message = _extractMessage(data);
    final errors = _extractErrors(data);

    return ApiFailure(message: message, statusCode: statusCode, errors: errors);
  }

  // Extract message from response (improved)
  String _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] ??
          data['error'] ??
          data['msg'] ??
          'An error occurred';
    }
    return 'An error occurred';
  }

  // Extract validation errors
  Map<String, List<String>>? _extractErrors(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['errors'] is Map) {
        final raw = data['errors'] as Map<String, dynamic>;
        return raw.map((key, value) {
          if (value is List) {
            return MapEntry(key, value.map((e) => e.toString()).toList());
          }
          return MapEntry(key, [value.toString()]);
        });
      }
    }
    return null;
  }

  // Improved no-internet detection
  String _getNetworkErrorMessage(DioException e) {
    if (e.error is SocketException) {
      return 'No internet connection.';
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout.';
      case DioExceptionType.sendTimeout:
        return 'Request send timeout.';
      case DioExceptionType.receiveTimeout:
        return 'Server took too long to respond.';
      case DioExceptionType.connectionError:
        return 'Network connection error.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      default:
        return 'Network error occurred.';
    }
  }
}
