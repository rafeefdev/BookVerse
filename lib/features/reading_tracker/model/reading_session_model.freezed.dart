// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reading_session_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReadingSessionModel {

 String get bookId; int get durationInSeconds; int get endPage; DateTime get timestamp;
/// Create a copy of ReadingSessionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReadingSessionModelCopyWith<ReadingSessionModel> get copyWith => _$ReadingSessionModelCopyWithImpl<ReadingSessionModel>(this as ReadingSessionModel, _$identity);

  /// Serializes this ReadingSessionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReadingSessionModel&&(identical(other.bookId, bookId) || other.bookId == bookId)&&(identical(other.durationInSeconds, durationInSeconds) || other.durationInSeconds == durationInSeconds)&&(identical(other.endPage, endPage) || other.endPage == endPage)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bookId,durationInSeconds,endPage,timestamp);

@override
String toString() {
  return 'ReadingSessionModel(bookId: $bookId, durationInSeconds: $durationInSeconds, endPage: $endPage, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class $ReadingSessionModelCopyWith<$Res>  {
  factory $ReadingSessionModelCopyWith(ReadingSessionModel value, $Res Function(ReadingSessionModel) _then) = _$ReadingSessionModelCopyWithImpl;
@useResult
$Res call({
 String bookId, int durationInSeconds, int endPage, DateTime timestamp
});




}
/// @nodoc
class _$ReadingSessionModelCopyWithImpl<$Res>
    implements $ReadingSessionModelCopyWith<$Res> {
  _$ReadingSessionModelCopyWithImpl(this._self, this._then);

  final ReadingSessionModel _self;
  final $Res Function(ReadingSessionModel) _then;

/// Create a copy of ReadingSessionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bookId = null,Object? durationInSeconds = null,Object? endPage = null,Object? timestamp = null,}) {
  return _then(_self.copyWith(
bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as String,durationInSeconds: null == durationInSeconds ? _self.durationInSeconds : durationInSeconds // ignore: cast_nullable_to_non_nullable
as int,endPage: null == endPage ? _self.endPage : endPage // ignore: cast_nullable_to_non_nullable
as int,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ReadingSessionModel].
extension ReadingSessionModelPatterns on ReadingSessionModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReadingSessionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReadingSessionModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReadingSessionModel value)  $default,){
final _that = this;
switch (_that) {
case _ReadingSessionModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReadingSessionModel value)?  $default,){
final _that = this;
switch (_that) {
case _ReadingSessionModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String bookId,  int durationInSeconds,  int endPage,  DateTime timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReadingSessionModel() when $default != null:
return $default(_that.bookId,_that.durationInSeconds,_that.endPage,_that.timestamp);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String bookId,  int durationInSeconds,  int endPage,  DateTime timestamp)  $default,) {final _that = this;
switch (_that) {
case _ReadingSessionModel():
return $default(_that.bookId,_that.durationInSeconds,_that.endPage,_that.timestamp);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String bookId,  int durationInSeconds,  int endPage,  DateTime timestamp)?  $default,) {final _that = this;
switch (_that) {
case _ReadingSessionModel() when $default != null:
return $default(_that.bookId,_that.durationInSeconds,_that.endPage,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReadingSessionModel implements ReadingSessionModel {
  const _ReadingSessionModel({required this.bookId, required this.durationInSeconds, required this.endPage, required this.timestamp});
  factory _ReadingSessionModel.fromJson(Map<String, dynamic> json) => _$ReadingSessionModelFromJson(json);

@override final  String bookId;
@override final  int durationInSeconds;
@override final  int endPage;
@override final  DateTime timestamp;

/// Create a copy of ReadingSessionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReadingSessionModelCopyWith<_ReadingSessionModel> get copyWith => __$ReadingSessionModelCopyWithImpl<_ReadingSessionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReadingSessionModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReadingSessionModel&&(identical(other.bookId, bookId) || other.bookId == bookId)&&(identical(other.durationInSeconds, durationInSeconds) || other.durationInSeconds == durationInSeconds)&&(identical(other.endPage, endPage) || other.endPage == endPage)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bookId,durationInSeconds,endPage,timestamp);

@override
String toString() {
  return 'ReadingSessionModel(bookId: $bookId, durationInSeconds: $durationInSeconds, endPage: $endPage, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$ReadingSessionModelCopyWith<$Res> implements $ReadingSessionModelCopyWith<$Res> {
  factory _$ReadingSessionModelCopyWith(_ReadingSessionModel value, $Res Function(_ReadingSessionModel) _then) = __$ReadingSessionModelCopyWithImpl;
@override @useResult
$Res call({
 String bookId, int durationInSeconds, int endPage, DateTime timestamp
});




}
/// @nodoc
class __$ReadingSessionModelCopyWithImpl<$Res>
    implements _$ReadingSessionModelCopyWith<$Res> {
  __$ReadingSessionModelCopyWithImpl(this._self, this._then);

  final _ReadingSessionModel _self;
  final $Res Function(_ReadingSessionModel) _then;

/// Create a copy of ReadingSessionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bookId = null,Object? durationInSeconds = null,Object? endPage = null,Object? timestamp = null,}) {
  return _then(_ReadingSessionModel(
bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as String,durationInSeconds: null == durationInSeconds ? _self.durationInSeconds : durationInSeconds // ignore: cast_nullable_to_non_nullable
as int,endPage: null == endPage ? _self.endPage : endPage // ignore: cast_nullable_to_non_nullable
as int,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
