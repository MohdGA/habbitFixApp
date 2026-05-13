import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/errors/app_exception.dart';

part 'auth_repository.g.dart';

class AuthCredentials {
  final String accessToken;
  final String refreshToken;
  final Map<String, dynamic> user;

  const AuthCredentials({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });
}

class AuthRepository {
  final Dio _dio;
  final SecureStorage _storage;

  AuthRepository(this._dio, this._storage);

  Future<AuthCredentials> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final data = response.data as Map<String, dynamic>;
      final creds = AuthCredentials(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
        user: data['user'] as Map<String, dynamic>,
      );

      await _storage.saveTokens(
        accessToken: creds.accessToken,
        refreshToken: creds.refreshToken,
      );
      await _storage.saveUserId(creds.user['id'] as String);

      return creds;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<AuthCredentials> register({
    required String email,
    required String username,
    required String displayName,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'email': email,
        'username': username,
        'displayName': displayName,
        'password': password,
      });

      final data = response.data as Map<String, dynamic>;
      final creds = AuthCredentials(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
        user: data['user'] as Map<String, dynamic>,
      );

      await _storage.saveTokens(
        accessToken: creds.accessToken,
        refreshToken: creds.refreshToken,
      );
      await _storage.saveUserId(creds.user['id'] as String);

      return creds;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken != null) {
        await _dio.post('/auth/logout', data: {'refreshToken': refreshToken});
      }
    } catch (_) {
      // Always clear local storage even if API call fails
    } finally {
      await _storage.clearAll();
    }
  }

  Future<bool> isLoggedIn() => _storage.hasTokens();

  AppException _mapDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    final message = (e.response?.data as Map<String, dynamic>?)?['message'] as String?;

    if (statusCode == 401) return AppException.unauthorized(message: message ?? 'Invalid email or password');
    if (statusCode == 409) return AppException.validation(message: message ?? 'Account already exists');
    if (statusCode == 400) return AppException.validation(message: message ?? 'Invalid input');
    return AppException.network(message: message ?? 'Network error');
  }
}

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepository(
    ref.watch(dioProvider),
    ref.watch(secureStorageProvider),
  );
}
