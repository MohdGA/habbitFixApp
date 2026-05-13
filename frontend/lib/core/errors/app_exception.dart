import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_exception.freezed.dart';

@freezed
sealed class AppException with _$AppException implements Exception {
  const AppException._();
  const factory AppException.network({required String message}) = NetworkException;
  const factory AppException.unauthorized({@Default('Session expired. Please log in again.') String message}) = UnauthorizedException;
  const factory AppException.notFound({required String message}) = NotFoundException;
  const factory AppException.validation({required String message, List<String>? fields}) = ValidationException;
  const factory AppException.server({required String message, int? statusCode}) = ServerException;
  const factory AppException.timeout({@Default('Request timed out. Please try again.') String message}) = TimeoutException;
  const factory AppException.unknown({required String message}) = UnknownException;
  const factory AppException.rateLimited({@Default('Too many requests. Please slow down.') String message}) = RateLimitException;

  String get userMessage => when(
    network: (msg) => msg,
    unauthorized: (msg) => msg,
    notFound: (msg) => msg,
    validation: (msg, _) => msg,
    server: (msg, _) => msg,
    timeout: (msg) => msg,
    unknown: (msg) => msg,
    rateLimited: (msg) => msg,
  );
}
