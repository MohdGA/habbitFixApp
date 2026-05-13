import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/secure_storage.dart';
import '../errors/app_exception.dart';

const _baseUrl = String.fromEnvironment('API_URL', defaultValue: 'http://localhost:4000/api/v1');

// Mutex for refresh token concurrency
bool _isRefreshing = false;
final List<Completer<void>> _pendingRequests = [];

Dio createDio(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  final storage = ref.read(secureStorageProvider);

  // Auth interceptor
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (DioException err, handler) async {
        if (err.response?.statusCode == 401) {
          // Don't retry auth endpoints
          if (err.requestOptions.path.contains('/auth/')) {
            return handler.next(err);
          }

          if (_isRefreshing) {
            // Queue up
            final completer = Completer<void>();
            _pendingRequests.add(completer);
            await completer.future;
            return handler.resolve(await _retry(dio, err.requestOptions, storage));
          }

          _isRefreshing = true;
          try {
            await _refreshTokens(dio, storage);
            // Resolve pending
            for (final c in _pendingRequests) c.complete();
            _pendingRequests.clear();
            return handler.resolve(await _retry(dio, err.requestOptions, storage));
          } catch (_) {
            await storage.clearAll();
            for (final c in _pendingRequests) c.completeError(const AppException.unauthorized());
            _pendingRequests.clear();
            return handler.reject(DioException(
              requestOptions: err.requestOptions,
              error: const AppException.unauthorized(),
              type: DioExceptionType.unknown,
            ));
          } finally {
            _isRefreshing = false;
          }
        }

        handler.next(err);
      },
    ),
  );

  return dio;
}

Future<void> _refreshTokens(Dio dio, SecureStorage storage) async {
  final refreshToken = await storage.getRefreshToken();
  if (refreshToken == null) throw const AppException.unauthorized();

  final response = await Dio(BaseOptions(baseUrl: _baseUrl)).post(
    '/auth/refresh',
    data: {'refreshToken': refreshToken},
  );

  final data = response.data as Map<String, dynamic>;
  await storage.saveTokens(
    accessToken: data['accessToken'] as String,
    refreshToken: data['refreshToken'] as String,
  );
}

Future<Response> _retry(Dio dio, RequestOptions options, SecureStorage storage) async {
  final token = await storage.getAccessToken();
  return dio.request(
    options.path,
    data: options.data,
    queryParameters: options.queryParameters,
    options: Options(
      method: options.method,
      headers: {
        ...options.headers,
        'Authorization': 'Bearer $token',
      },
    ),
  );
}

AppException mapDioError(DioException err) {
  switch (err.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
      return const AppException.timeout();
    case DioExceptionType.connectionError:
      return const AppException.network(message: 'No internet connection. Check your network.');
    default:
      final statusCode = err.response?.statusCode;
      final message = (err.response?.data as Map<String, dynamic>?)?['message'] as String? ?? err.message ?? 'Unknown error';
      if (statusCode == 401) return const AppException.unauthorized();
      if (statusCode == 404) return AppException.notFound(message: message);
      if (statusCode == 422 || statusCode == 400) return AppException.validation(message: message);
      if (statusCode == 429) return const AppException.rateLimited();
      if (statusCode != null && statusCode >= 500) return AppException.server(message: 'Server error. Please try again later.', statusCode: statusCode);
      return AppException.unknown(message: message);
  }
}

final dioProvider = Provider<Dio>((ref) => createDio(ref));
