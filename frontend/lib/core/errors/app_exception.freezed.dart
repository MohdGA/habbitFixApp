// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_exception.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AppException {
  String get message => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) network,
    required TResult Function(String message) unauthorized,
    required TResult Function(String message) notFound,
    required TResult Function(String message, List<String>? fields) validation,
    required TResult Function(String message, int? statusCode) server,
    required TResult Function(String message) timeout,
    required TResult Function(String message) unknown,
    required TResult Function(String message) rateLimited,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? network,
    TResult? Function(String message)? unauthorized,
    TResult? Function(String message)? notFound,
    TResult? Function(String message, List<String>? fields)? validation,
    TResult? Function(String message, int? statusCode)? server,
    TResult? Function(String message)? timeout,
    TResult? Function(String message)? unknown,
    TResult? Function(String message)? rateLimited,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? network,
    TResult Function(String message)? unauthorized,
    TResult Function(String message)? notFound,
    TResult Function(String message, List<String>? fields)? validation,
    TResult Function(String message, int? statusCode)? server,
    TResult Function(String message)? timeout,
    TResult Function(String message)? unknown,
    TResult Function(String message)? rateLimited,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkException value) network,
    required TResult Function(UnauthorizedException value) unauthorized,
    required TResult Function(NotFoundException value) notFound,
    required TResult Function(ValidationException value) validation,
    required TResult Function(ServerException value) server,
    required TResult Function(TimeoutException value) timeout,
    required TResult Function(UnknownException value) unknown,
    required TResult Function(RateLimitException value) rateLimited,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkException value)? network,
    TResult? Function(UnauthorizedException value)? unauthorized,
    TResult? Function(NotFoundException value)? notFound,
    TResult? Function(ValidationException value)? validation,
    TResult? Function(ServerException value)? server,
    TResult? Function(TimeoutException value)? timeout,
    TResult? Function(UnknownException value)? unknown,
    TResult? Function(RateLimitException value)? rateLimited,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkException value)? network,
    TResult Function(UnauthorizedException value)? unauthorized,
    TResult Function(NotFoundException value)? notFound,
    TResult Function(ValidationException value)? validation,
    TResult Function(ServerException value)? server,
    TResult Function(TimeoutException value)? timeout,
    TResult Function(UnknownException value)? unknown,
    TResult Function(RateLimitException value)? rateLimited,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppExceptionCopyWith<AppException> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppExceptionCopyWith<$Res> {
  factory $AppExceptionCopyWith(
          AppException value, $Res Function(AppException) then) =
      _$AppExceptionCopyWithImpl<$Res, AppException>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class _$AppExceptionCopyWithImpl<$Res, $Val extends AppException>
    implements $AppExceptionCopyWith<$Res> {
  _$AppExceptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_value.copyWith(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NetworkExceptionImplCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory _$$NetworkExceptionImplCopyWith(_$NetworkExceptionImpl value,
          $Res Function(_$NetworkExceptionImpl) then) =
      __$$NetworkExceptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$NetworkExceptionImplCopyWithImpl<$Res>
    extends _$AppExceptionCopyWithImpl<$Res, _$NetworkExceptionImpl>
    implements _$$NetworkExceptionImplCopyWith<$Res> {
  __$$NetworkExceptionImplCopyWithImpl(_$NetworkExceptionImpl _value,
      $Res Function(_$NetworkExceptionImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$NetworkExceptionImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$NetworkExceptionImpl extends NetworkException {
  const _$NetworkExceptionImpl({required this.message}) : super._();

  @override
  final String message;

  @override
  String toString() {
    return 'AppException.network(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NetworkExceptionImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NetworkExceptionImplCopyWith<_$NetworkExceptionImpl> get copyWith =>
      __$$NetworkExceptionImplCopyWithImpl<_$NetworkExceptionImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) network,
    required TResult Function(String message) unauthorized,
    required TResult Function(String message) notFound,
    required TResult Function(String message, List<String>? fields) validation,
    required TResult Function(String message, int? statusCode) server,
    required TResult Function(String message) timeout,
    required TResult Function(String message) unknown,
    required TResult Function(String message) rateLimited,
  }) {
    return network(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? network,
    TResult? Function(String message)? unauthorized,
    TResult? Function(String message)? notFound,
    TResult? Function(String message, List<String>? fields)? validation,
    TResult? Function(String message, int? statusCode)? server,
    TResult? Function(String message)? timeout,
    TResult? Function(String message)? unknown,
    TResult? Function(String message)? rateLimited,
  }) {
    return network?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? network,
    TResult Function(String message)? unauthorized,
    TResult Function(String message)? notFound,
    TResult Function(String message, List<String>? fields)? validation,
    TResult Function(String message, int? statusCode)? server,
    TResult Function(String message)? timeout,
    TResult Function(String message)? unknown,
    TResult Function(String message)? rateLimited,
    required TResult orElse(),
  }) {
    if (network != null) {
      return network(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkException value) network,
    required TResult Function(UnauthorizedException value) unauthorized,
    required TResult Function(NotFoundException value) notFound,
    required TResult Function(ValidationException value) validation,
    required TResult Function(ServerException value) server,
    required TResult Function(TimeoutException value) timeout,
    required TResult Function(UnknownException value) unknown,
    required TResult Function(RateLimitException value) rateLimited,
  }) {
    return network(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkException value)? network,
    TResult? Function(UnauthorizedException value)? unauthorized,
    TResult? Function(NotFoundException value)? notFound,
    TResult? Function(ValidationException value)? validation,
    TResult? Function(ServerException value)? server,
    TResult? Function(TimeoutException value)? timeout,
    TResult? Function(UnknownException value)? unknown,
    TResult? Function(RateLimitException value)? rateLimited,
  }) {
    return network?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkException value)? network,
    TResult Function(UnauthorizedException value)? unauthorized,
    TResult Function(NotFoundException value)? notFound,
    TResult Function(ValidationException value)? validation,
    TResult Function(ServerException value)? server,
    TResult Function(TimeoutException value)? timeout,
    TResult Function(UnknownException value)? unknown,
    TResult Function(RateLimitException value)? rateLimited,
    required TResult orElse(),
  }) {
    if (network != null) {
      return network(this);
    }
    return orElse();
  }
}

abstract class NetworkException extends AppException {
  const factory NetworkException({required final String message}) =
      _$NetworkExceptionImpl;
  const NetworkException._() : super._();

  @override
  String get message;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NetworkExceptionImplCopyWith<_$NetworkExceptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UnauthorizedExceptionImplCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory _$$UnauthorizedExceptionImplCopyWith(
          _$UnauthorizedExceptionImpl value,
          $Res Function(_$UnauthorizedExceptionImpl) then) =
      __$$UnauthorizedExceptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$UnauthorizedExceptionImplCopyWithImpl<$Res>
    extends _$AppExceptionCopyWithImpl<$Res, _$UnauthorizedExceptionImpl>
    implements _$$UnauthorizedExceptionImplCopyWith<$Res> {
  __$$UnauthorizedExceptionImplCopyWithImpl(_$UnauthorizedExceptionImpl _value,
      $Res Function(_$UnauthorizedExceptionImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$UnauthorizedExceptionImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$UnauthorizedExceptionImpl extends UnauthorizedException {
  const _$UnauthorizedExceptionImpl(
      {this.message = 'Session expired. Please log in again.'})
      : super._();

  @override
  @JsonKey()
  final String message;

  @override
  String toString() {
    return 'AppException.unauthorized(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnauthorizedExceptionImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UnauthorizedExceptionImplCopyWith<_$UnauthorizedExceptionImpl>
      get copyWith => __$$UnauthorizedExceptionImplCopyWithImpl<
          _$UnauthorizedExceptionImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) network,
    required TResult Function(String message) unauthorized,
    required TResult Function(String message) notFound,
    required TResult Function(String message, List<String>? fields) validation,
    required TResult Function(String message, int? statusCode) server,
    required TResult Function(String message) timeout,
    required TResult Function(String message) unknown,
    required TResult Function(String message) rateLimited,
  }) {
    return unauthorized(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? network,
    TResult? Function(String message)? unauthorized,
    TResult? Function(String message)? notFound,
    TResult? Function(String message, List<String>? fields)? validation,
    TResult? Function(String message, int? statusCode)? server,
    TResult? Function(String message)? timeout,
    TResult? Function(String message)? unknown,
    TResult? Function(String message)? rateLimited,
  }) {
    return unauthorized?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? network,
    TResult Function(String message)? unauthorized,
    TResult Function(String message)? notFound,
    TResult Function(String message, List<String>? fields)? validation,
    TResult Function(String message, int? statusCode)? server,
    TResult Function(String message)? timeout,
    TResult Function(String message)? unknown,
    TResult Function(String message)? rateLimited,
    required TResult orElse(),
  }) {
    if (unauthorized != null) {
      return unauthorized(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkException value) network,
    required TResult Function(UnauthorizedException value) unauthorized,
    required TResult Function(NotFoundException value) notFound,
    required TResult Function(ValidationException value) validation,
    required TResult Function(ServerException value) server,
    required TResult Function(TimeoutException value) timeout,
    required TResult Function(UnknownException value) unknown,
    required TResult Function(RateLimitException value) rateLimited,
  }) {
    return unauthorized(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkException value)? network,
    TResult? Function(UnauthorizedException value)? unauthorized,
    TResult? Function(NotFoundException value)? notFound,
    TResult? Function(ValidationException value)? validation,
    TResult? Function(ServerException value)? server,
    TResult? Function(TimeoutException value)? timeout,
    TResult? Function(UnknownException value)? unknown,
    TResult? Function(RateLimitException value)? rateLimited,
  }) {
    return unauthorized?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkException value)? network,
    TResult Function(UnauthorizedException value)? unauthorized,
    TResult Function(NotFoundException value)? notFound,
    TResult Function(ValidationException value)? validation,
    TResult Function(ServerException value)? server,
    TResult Function(TimeoutException value)? timeout,
    TResult Function(UnknownException value)? unknown,
    TResult Function(RateLimitException value)? rateLimited,
    required TResult orElse(),
  }) {
    if (unauthorized != null) {
      return unauthorized(this);
    }
    return orElse();
  }
}

abstract class UnauthorizedException extends AppException {
  const factory UnauthorizedException({final String message}) =
      _$UnauthorizedExceptionImpl;
  const UnauthorizedException._() : super._();

  @override
  String get message;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UnauthorizedExceptionImplCopyWith<_$UnauthorizedExceptionImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$NotFoundExceptionImplCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory _$$NotFoundExceptionImplCopyWith(_$NotFoundExceptionImpl value,
          $Res Function(_$NotFoundExceptionImpl) then) =
      __$$NotFoundExceptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$NotFoundExceptionImplCopyWithImpl<$Res>
    extends _$AppExceptionCopyWithImpl<$Res, _$NotFoundExceptionImpl>
    implements _$$NotFoundExceptionImplCopyWith<$Res> {
  __$$NotFoundExceptionImplCopyWithImpl(_$NotFoundExceptionImpl _value,
      $Res Function(_$NotFoundExceptionImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$NotFoundExceptionImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$NotFoundExceptionImpl extends NotFoundException {
  const _$NotFoundExceptionImpl({required this.message}) : super._();

  @override
  final String message;

  @override
  String toString() {
    return 'AppException.notFound(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotFoundExceptionImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotFoundExceptionImplCopyWith<_$NotFoundExceptionImpl> get copyWith =>
      __$$NotFoundExceptionImplCopyWithImpl<_$NotFoundExceptionImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) network,
    required TResult Function(String message) unauthorized,
    required TResult Function(String message) notFound,
    required TResult Function(String message, List<String>? fields) validation,
    required TResult Function(String message, int? statusCode) server,
    required TResult Function(String message) timeout,
    required TResult Function(String message) unknown,
    required TResult Function(String message) rateLimited,
  }) {
    return notFound(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? network,
    TResult? Function(String message)? unauthorized,
    TResult? Function(String message)? notFound,
    TResult? Function(String message, List<String>? fields)? validation,
    TResult? Function(String message, int? statusCode)? server,
    TResult? Function(String message)? timeout,
    TResult? Function(String message)? unknown,
    TResult? Function(String message)? rateLimited,
  }) {
    return notFound?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? network,
    TResult Function(String message)? unauthorized,
    TResult Function(String message)? notFound,
    TResult Function(String message, List<String>? fields)? validation,
    TResult Function(String message, int? statusCode)? server,
    TResult Function(String message)? timeout,
    TResult Function(String message)? unknown,
    TResult Function(String message)? rateLimited,
    required TResult orElse(),
  }) {
    if (notFound != null) {
      return notFound(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkException value) network,
    required TResult Function(UnauthorizedException value) unauthorized,
    required TResult Function(NotFoundException value) notFound,
    required TResult Function(ValidationException value) validation,
    required TResult Function(ServerException value) server,
    required TResult Function(TimeoutException value) timeout,
    required TResult Function(UnknownException value) unknown,
    required TResult Function(RateLimitException value) rateLimited,
  }) {
    return notFound(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkException value)? network,
    TResult? Function(UnauthorizedException value)? unauthorized,
    TResult? Function(NotFoundException value)? notFound,
    TResult? Function(ValidationException value)? validation,
    TResult? Function(ServerException value)? server,
    TResult? Function(TimeoutException value)? timeout,
    TResult? Function(UnknownException value)? unknown,
    TResult? Function(RateLimitException value)? rateLimited,
  }) {
    return notFound?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkException value)? network,
    TResult Function(UnauthorizedException value)? unauthorized,
    TResult Function(NotFoundException value)? notFound,
    TResult Function(ValidationException value)? validation,
    TResult Function(ServerException value)? server,
    TResult Function(TimeoutException value)? timeout,
    TResult Function(UnknownException value)? unknown,
    TResult Function(RateLimitException value)? rateLimited,
    required TResult orElse(),
  }) {
    if (notFound != null) {
      return notFound(this);
    }
    return orElse();
  }
}

abstract class NotFoundException extends AppException {
  const factory NotFoundException({required final String message}) =
      _$NotFoundExceptionImpl;
  const NotFoundException._() : super._();

  @override
  String get message;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotFoundExceptionImplCopyWith<_$NotFoundExceptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ValidationExceptionImplCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory _$$ValidationExceptionImplCopyWith(_$ValidationExceptionImpl value,
          $Res Function(_$ValidationExceptionImpl) then) =
      __$$ValidationExceptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, List<String>? fields});
}

/// @nodoc
class __$$ValidationExceptionImplCopyWithImpl<$Res>
    extends _$AppExceptionCopyWithImpl<$Res, _$ValidationExceptionImpl>
    implements _$$ValidationExceptionImplCopyWith<$Res> {
  __$$ValidationExceptionImplCopyWithImpl(_$ValidationExceptionImpl _value,
      $Res Function(_$ValidationExceptionImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? fields = freezed,
  }) {
    return _then(_$ValidationExceptionImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      fields: freezed == fields
          ? _value._fields
          : fields // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc

class _$ValidationExceptionImpl extends ValidationException {
  const _$ValidationExceptionImpl(
      {required this.message, final List<String>? fields})
      : _fields = fields,
        super._();

  @override
  final String message;
  final List<String>? _fields;
  @override
  List<String>? get fields {
    final value = _fields;
    if (value == null) return null;
    if (_fields is EqualUnmodifiableListView) return _fields;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'AppException.validation(message: $message, fields: $fields)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ValidationExceptionImpl &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other._fields, _fields));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, message, const DeepCollectionEquality().hash(_fields));

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ValidationExceptionImplCopyWith<_$ValidationExceptionImpl> get copyWith =>
      __$$ValidationExceptionImplCopyWithImpl<_$ValidationExceptionImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) network,
    required TResult Function(String message) unauthorized,
    required TResult Function(String message) notFound,
    required TResult Function(String message, List<String>? fields) validation,
    required TResult Function(String message, int? statusCode) server,
    required TResult Function(String message) timeout,
    required TResult Function(String message) unknown,
    required TResult Function(String message) rateLimited,
  }) {
    return validation(message, fields);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? network,
    TResult? Function(String message)? unauthorized,
    TResult? Function(String message)? notFound,
    TResult? Function(String message, List<String>? fields)? validation,
    TResult? Function(String message, int? statusCode)? server,
    TResult? Function(String message)? timeout,
    TResult? Function(String message)? unknown,
    TResult? Function(String message)? rateLimited,
  }) {
    return validation?.call(message, fields);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? network,
    TResult Function(String message)? unauthorized,
    TResult Function(String message)? notFound,
    TResult Function(String message, List<String>? fields)? validation,
    TResult Function(String message, int? statusCode)? server,
    TResult Function(String message)? timeout,
    TResult Function(String message)? unknown,
    TResult Function(String message)? rateLimited,
    required TResult orElse(),
  }) {
    if (validation != null) {
      return validation(message, fields);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkException value) network,
    required TResult Function(UnauthorizedException value) unauthorized,
    required TResult Function(NotFoundException value) notFound,
    required TResult Function(ValidationException value) validation,
    required TResult Function(ServerException value) server,
    required TResult Function(TimeoutException value) timeout,
    required TResult Function(UnknownException value) unknown,
    required TResult Function(RateLimitException value) rateLimited,
  }) {
    return validation(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkException value)? network,
    TResult? Function(UnauthorizedException value)? unauthorized,
    TResult? Function(NotFoundException value)? notFound,
    TResult? Function(ValidationException value)? validation,
    TResult? Function(ServerException value)? server,
    TResult? Function(TimeoutException value)? timeout,
    TResult? Function(UnknownException value)? unknown,
    TResult? Function(RateLimitException value)? rateLimited,
  }) {
    return validation?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkException value)? network,
    TResult Function(UnauthorizedException value)? unauthorized,
    TResult Function(NotFoundException value)? notFound,
    TResult Function(ValidationException value)? validation,
    TResult Function(ServerException value)? server,
    TResult Function(TimeoutException value)? timeout,
    TResult Function(UnknownException value)? unknown,
    TResult Function(RateLimitException value)? rateLimited,
    required TResult orElse(),
  }) {
    if (validation != null) {
      return validation(this);
    }
    return orElse();
  }
}

abstract class ValidationException extends AppException {
  const factory ValidationException(
      {required final String message,
      final List<String>? fields}) = _$ValidationExceptionImpl;
  const ValidationException._() : super._();

  @override
  String get message;
  List<String>? get fields;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ValidationExceptionImplCopyWith<_$ValidationExceptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ServerExceptionImplCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory _$$ServerExceptionImplCopyWith(_$ServerExceptionImpl value,
          $Res Function(_$ServerExceptionImpl) then) =
      __$$ServerExceptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, int? statusCode});
}

/// @nodoc
class __$$ServerExceptionImplCopyWithImpl<$Res>
    extends _$AppExceptionCopyWithImpl<$Res, _$ServerExceptionImpl>
    implements _$$ServerExceptionImplCopyWith<$Res> {
  __$$ServerExceptionImplCopyWithImpl(
      _$ServerExceptionImpl _value, $Res Function(_$ServerExceptionImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? statusCode = freezed,
  }) {
    return _then(_$ServerExceptionImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      statusCode: freezed == statusCode
          ? _value.statusCode
          : statusCode // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$ServerExceptionImpl extends ServerException {
  const _$ServerExceptionImpl({required this.message, this.statusCode})
      : super._();

  @override
  final String message;
  @override
  final int? statusCode;

  @override
  String toString() {
    return 'AppException.server(message: $message, statusCode: $statusCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServerExceptionImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.statusCode, statusCode) ||
                other.statusCode == statusCode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, statusCode);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ServerExceptionImplCopyWith<_$ServerExceptionImpl> get copyWith =>
      __$$ServerExceptionImplCopyWithImpl<_$ServerExceptionImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) network,
    required TResult Function(String message) unauthorized,
    required TResult Function(String message) notFound,
    required TResult Function(String message, List<String>? fields) validation,
    required TResult Function(String message, int? statusCode) server,
    required TResult Function(String message) timeout,
    required TResult Function(String message) unknown,
    required TResult Function(String message) rateLimited,
  }) {
    return server(message, statusCode);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? network,
    TResult? Function(String message)? unauthorized,
    TResult? Function(String message)? notFound,
    TResult? Function(String message, List<String>? fields)? validation,
    TResult? Function(String message, int? statusCode)? server,
    TResult? Function(String message)? timeout,
    TResult? Function(String message)? unknown,
    TResult? Function(String message)? rateLimited,
  }) {
    return server?.call(message, statusCode);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? network,
    TResult Function(String message)? unauthorized,
    TResult Function(String message)? notFound,
    TResult Function(String message, List<String>? fields)? validation,
    TResult Function(String message, int? statusCode)? server,
    TResult Function(String message)? timeout,
    TResult Function(String message)? unknown,
    TResult Function(String message)? rateLimited,
    required TResult orElse(),
  }) {
    if (server != null) {
      return server(message, statusCode);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkException value) network,
    required TResult Function(UnauthorizedException value) unauthorized,
    required TResult Function(NotFoundException value) notFound,
    required TResult Function(ValidationException value) validation,
    required TResult Function(ServerException value) server,
    required TResult Function(TimeoutException value) timeout,
    required TResult Function(UnknownException value) unknown,
    required TResult Function(RateLimitException value) rateLimited,
  }) {
    return server(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkException value)? network,
    TResult? Function(UnauthorizedException value)? unauthorized,
    TResult? Function(NotFoundException value)? notFound,
    TResult? Function(ValidationException value)? validation,
    TResult? Function(ServerException value)? server,
    TResult? Function(TimeoutException value)? timeout,
    TResult? Function(UnknownException value)? unknown,
    TResult? Function(RateLimitException value)? rateLimited,
  }) {
    return server?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkException value)? network,
    TResult Function(UnauthorizedException value)? unauthorized,
    TResult Function(NotFoundException value)? notFound,
    TResult Function(ValidationException value)? validation,
    TResult Function(ServerException value)? server,
    TResult Function(TimeoutException value)? timeout,
    TResult Function(UnknownException value)? unknown,
    TResult Function(RateLimitException value)? rateLimited,
    required TResult orElse(),
  }) {
    if (server != null) {
      return server(this);
    }
    return orElse();
  }
}

abstract class ServerException extends AppException {
  const factory ServerException(
      {required final String message,
      final int? statusCode}) = _$ServerExceptionImpl;
  const ServerException._() : super._();

  @override
  String get message;
  int? get statusCode;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ServerExceptionImplCopyWith<_$ServerExceptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TimeoutExceptionImplCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory _$$TimeoutExceptionImplCopyWith(_$TimeoutExceptionImpl value,
          $Res Function(_$TimeoutExceptionImpl) then) =
      __$$TimeoutExceptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$TimeoutExceptionImplCopyWithImpl<$Res>
    extends _$AppExceptionCopyWithImpl<$Res, _$TimeoutExceptionImpl>
    implements _$$TimeoutExceptionImplCopyWith<$Res> {
  __$$TimeoutExceptionImplCopyWithImpl(_$TimeoutExceptionImpl _value,
      $Res Function(_$TimeoutExceptionImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$TimeoutExceptionImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$TimeoutExceptionImpl extends TimeoutException {
  const _$TimeoutExceptionImpl(
      {this.message = 'Request timed out. Please try again.'})
      : super._();

  @override
  @JsonKey()
  final String message;

  @override
  String toString() {
    return 'AppException.timeout(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimeoutExceptionImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimeoutExceptionImplCopyWith<_$TimeoutExceptionImpl> get copyWith =>
      __$$TimeoutExceptionImplCopyWithImpl<_$TimeoutExceptionImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) network,
    required TResult Function(String message) unauthorized,
    required TResult Function(String message) notFound,
    required TResult Function(String message, List<String>? fields) validation,
    required TResult Function(String message, int? statusCode) server,
    required TResult Function(String message) timeout,
    required TResult Function(String message) unknown,
    required TResult Function(String message) rateLimited,
  }) {
    return timeout(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? network,
    TResult? Function(String message)? unauthorized,
    TResult? Function(String message)? notFound,
    TResult? Function(String message, List<String>? fields)? validation,
    TResult? Function(String message, int? statusCode)? server,
    TResult? Function(String message)? timeout,
    TResult? Function(String message)? unknown,
    TResult? Function(String message)? rateLimited,
  }) {
    return timeout?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? network,
    TResult Function(String message)? unauthorized,
    TResult Function(String message)? notFound,
    TResult Function(String message, List<String>? fields)? validation,
    TResult Function(String message, int? statusCode)? server,
    TResult Function(String message)? timeout,
    TResult Function(String message)? unknown,
    TResult Function(String message)? rateLimited,
    required TResult orElse(),
  }) {
    if (timeout != null) {
      return timeout(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkException value) network,
    required TResult Function(UnauthorizedException value) unauthorized,
    required TResult Function(NotFoundException value) notFound,
    required TResult Function(ValidationException value) validation,
    required TResult Function(ServerException value) server,
    required TResult Function(TimeoutException value) timeout,
    required TResult Function(UnknownException value) unknown,
    required TResult Function(RateLimitException value) rateLimited,
  }) {
    return timeout(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkException value)? network,
    TResult? Function(UnauthorizedException value)? unauthorized,
    TResult? Function(NotFoundException value)? notFound,
    TResult? Function(ValidationException value)? validation,
    TResult? Function(ServerException value)? server,
    TResult? Function(TimeoutException value)? timeout,
    TResult? Function(UnknownException value)? unknown,
    TResult? Function(RateLimitException value)? rateLimited,
  }) {
    return timeout?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkException value)? network,
    TResult Function(UnauthorizedException value)? unauthorized,
    TResult Function(NotFoundException value)? notFound,
    TResult Function(ValidationException value)? validation,
    TResult Function(ServerException value)? server,
    TResult Function(TimeoutException value)? timeout,
    TResult Function(UnknownException value)? unknown,
    TResult Function(RateLimitException value)? rateLimited,
    required TResult orElse(),
  }) {
    if (timeout != null) {
      return timeout(this);
    }
    return orElse();
  }
}

abstract class TimeoutException extends AppException {
  const factory TimeoutException({final String message}) =
      _$TimeoutExceptionImpl;
  const TimeoutException._() : super._();

  @override
  String get message;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimeoutExceptionImplCopyWith<_$TimeoutExceptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UnknownExceptionImplCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory _$$UnknownExceptionImplCopyWith(_$UnknownExceptionImpl value,
          $Res Function(_$UnknownExceptionImpl) then) =
      __$$UnknownExceptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$UnknownExceptionImplCopyWithImpl<$Res>
    extends _$AppExceptionCopyWithImpl<$Res, _$UnknownExceptionImpl>
    implements _$$UnknownExceptionImplCopyWith<$Res> {
  __$$UnknownExceptionImplCopyWithImpl(_$UnknownExceptionImpl _value,
      $Res Function(_$UnknownExceptionImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$UnknownExceptionImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$UnknownExceptionImpl extends UnknownException {
  const _$UnknownExceptionImpl({required this.message}) : super._();

  @override
  final String message;

  @override
  String toString() {
    return 'AppException.unknown(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnknownExceptionImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UnknownExceptionImplCopyWith<_$UnknownExceptionImpl> get copyWith =>
      __$$UnknownExceptionImplCopyWithImpl<_$UnknownExceptionImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) network,
    required TResult Function(String message) unauthorized,
    required TResult Function(String message) notFound,
    required TResult Function(String message, List<String>? fields) validation,
    required TResult Function(String message, int? statusCode) server,
    required TResult Function(String message) timeout,
    required TResult Function(String message) unknown,
    required TResult Function(String message) rateLimited,
  }) {
    return unknown(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? network,
    TResult? Function(String message)? unauthorized,
    TResult? Function(String message)? notFound,
    TResult? Function(String message, List<String>? fields)? validation,
    TResult? Function(String message, int? statusCode)? server,
    TResult? Function(String message)? timeout,
    TResult? Function(String message)? unknown,
    TResult? Function(String message)? rateLimited,
  }) {
    return unknown?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? network,
    TResult Function(String message)? unauthorized,
    TResult Function(String message)? notFound,
    TResult Function(String message, List<String>? fields)? validation,
    TResult Function(String message, int? statusCode)? server,
    TResult Function(String message)? timeout,
    TResult Function(String message)? unknown,
    TResult Function(String message)? rateLimited,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkException value) network,
    required TResult Function(UnauthorizedException value) unauthorized,
    required TResult Function(NotFoundException value) notFound,
    required TResult Function(ValidationException value) validation,
    required TResult Function(ServerException value) server,
    required TResult Function(TimeoutException value) timeout,
    required TResult Function(UnknownException value) unknown,
    required TResult Function(RateLimitException value) rateLimited,
  }) {
    return unknown(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkException value)? network,
    TResult? Function(UnauthorizedException value)? unauthorized,
    TResult? Function(NotFoundException value)? notFound,
    TResult? Function(ValidationException value)? validation,
    TResult? Function(ServerException value)? server,
    TResult? Function(TimeoutException value)? timeout,
    TResult? Function(UnknownException value)? unknown,
    TResult? Function(RateLimitException value)? rateLimited,
  }) {
    return unknown?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkException value)? network,
    TResult Function(UnauthorizedException value)? unauthorized,
    TResult Function(NotFoundException value)? notFound,
    TResult Function(ValidationException value)? validation,
    TResult Function(ServerException value)? server,
    TResult Function(TimeoutException value)? timeout,
    TResult Function(UnknownException value)? unknown,
    TResult Function(RateLimitException value)? rateLimited,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(this);
    }
    return orElse();
  }
}

abstract class UnknownException extends AppException {
  const factory UnknownException({required final String message}) =
      _$UnknownExceptionImpl;
  const UnknownException._() : super._();

  @override
  String get message;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UnknownExceptionImplCopyWith<_$UnknownExceptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RateLimitExceptionImplCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory _$$RateLimitExceptionImplCopyWith(_$RateLimitExceptionImpl value,
          $Res Function(_$RateLimitExceptionImpl) then) =
      __$$RateLimitExceptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$RateLimitExceptionImplCopyWithImpl<$Res>
    extends _$AppExceptionCopyWithImpl<$Res, _$RateLimitExceptionImpl>
    implements _$$RateLimitExceptionImplCopyWith<$Res> {
  __$$RateLimitExceptionImplCopyWithImpl(_$RateLimitExceptionImpl _value,
      $Res Function(_$RateLimitExceptionImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$RateLimitExceptionImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$RateLimitExceptionImpl extends RateLimitException {
  const _$RateLimitExceptionImpl(
      {this.message = 'Too many requests. Please slow down.'})
      : super._();

  @override
  @JsonKey()
  final String message;

  @override
  String toString() {
    return 'AppException.rateLimited(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RateLimitExceptionImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RateLimitExceptionImplCopyWith<_$RateLimitExceptionImpl> get copyWith =>
      __$$RateLimitExceptionImplCopyWithImpl<_$RateLimitExceptionImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) network,
    required TResult Function(String message) unauthorized,
    required TResult Function(String message) notFound,
    required TResult Function(String message, List<String>? fields) validation,
    required TResult Function(String message, int? statusCode) server,
    required TResult Function(String message) timeout,
    required TResult Function(String message) unknown,
    required TResult Function(String message) rateLimited,
  }) {
    return rateLimited(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? network,
    TResult? Function(String message)? unauthorized,
    TResult? Function(String message)? notFound,
    TResult? Function(String message, List<String>? fields)? validation,
    TResult? Function(String message, int? statusCode)? server,
    TResult? Function(String message)? timeout,
    TResult? Function(String message)? unknown,
    TResult? Function(String message)? rateLimited,
  }) {
    return rateLimited?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? network,
    TResult Function(String message)? unauthorized,
    TResult Function(String message)? notFound,
    TResult Function(String message, List<String>? fields)? validation,
    TResult Function(String message, int? statusCode)? server,
    TResult Function(String message)? timeout,
    TResult Function(String message)? unknown,
    TResult Function(String message)? rateLimited,
    required TResult orElse(),
  }) {
    if (rateLimited != null) {
      return rateLimited(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkException value) network,
    required TResult Function(UnauthorizedException value) unauthorized,
    required TResult Function(NotFoundException value) notFound,
    required TResult Function(ValidationException value) validation,
    required TResult Function(ServerException value) server,
    required TResult Function(TimeoutException value) timeout,
    required TResult Function(UnknownException value) unknown,
    required TResult Function(RateLimitException value) rateLimited,
  }) {
    return rateLimited(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkException value)? network,
    TResult? Function(UnauthorizedException value)? unauthorized,
    TResult? Function(NotFoundException value)? notFound,
    TResult? Function(ValidationException value)? validation,
    TResult? Function(ServerException value)? server,
    TResult? Function(TimeoutException value)? timeout,
    TResult? Function(UnknownException value)? unknown,
    TResult? Function(RateLimitException value)? rateLimited,
  }) {
    return rateLimited?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkException value)? network,
    TResult Function(UnauthorizedException value)? unauthorized,
    TResult Function(NotFoundException value)? notFound,
    TResult Function(ValidationException value)? validation,
    TResult Function(ServerException value)? server,
    TResult Function(TimeoutException value)? timeout,
    TResult Function(UnknownException value)? unknown,
    TResult Function(RateLimitException value)? rateLimited,
    required TResult orElse(),
  }) {
    if (rateLimited != null) {
      return rateLimited(this);
    }
    return orElse();
  }
}

abstract class RateLimitException extends AppException {
  const factory RateLimitException({final String message}) =
      _$RateLimitExceptionImpl;
  const RateLimitException._() : super._();

  @override
  String get message;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RateLimitExceptionImplCopyWith<_$RateLimitExceptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
