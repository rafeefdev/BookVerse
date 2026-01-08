// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reading_progress_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReadingProgressModel {

 String get bookId; int get currentPage; int get totalReadingTimeInSeconds; DateTime? get lastRead; BookModel? get book;
/// Create a copy of ReadingProgressModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReadingProgressModelCopyWith<ReadingProgressModel> get copyWith => _$ReadingProgressModelCopyWithImpl<ReadingProgressModel>(this as ReadingProgressModel, _$identity);

  /// Serializes this ReadingProgressModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReadingProgressModel&&(identical(other.bookId, bookId) || other.bookId == bookId)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.totalReadingTimeInSeconds, totalReadingTimeInSeconds) || other.totalReadingTimeInSeconds == totalReadingTimeInSeconds)&&(identical(other.lastRead, lastRead) || other.lastRead == lastRead)&&const DeepCollectionEquality().equals(other.book, book));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bookId,currentPage,totalReadingTimeInSeconds,lastRead,const DeepCollectionEquality().hash(book));

@override
String toString() {
  return 'ReadingProgressModel(bookId: $bookId, currentPage: $currentPage, totalReadingTimeInSeconds: $totalReadingTimeInSeconds, lastRead: $lastRead, book: $book)';
}


}

/// @nodoc
abstract mixin class $ReadingProgressModelCopyWith<$Res>  {
  factory $ReadingProgressModelCopyWith(ReadingProgressModel value, $Res Function(ReadingProgressModel) _then) = _$ReadingProgressModelCopyWithImpl;
@useResult
$Res call({
 String bookId, int currentPage, int totalReadingTimeInSeconds, DateTime? lastRead, BookModel? book
});




}
/// @nodoc
class _$ReadingProgressModelCopyWithImpl<$Res>
    implements $ReadingProgressModelCopyWith<$Res> {
  _$ReadingProgressModelCopyWithImpl(this._self, this._then);

  final ReadingProgressModel _self;
  final $Res Function(ReadingProgressModel) _then;

/// Create a copy of ReadingProgressModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bookId = null,Object? currentPage = null,Object? totalReadingTimeInSeconds = null,Object? lastRead = freezed,Object? book = freezed,}) {
  return _then(_self.copyWith(
bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as String,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,totalReadingTimeInSeconds: null == totalReadingTimeInSeconds ? _self.totalReadingTimeInSeconds : totalReadingTimeInSeconds // ignore: cast_nullable_to_non_nullable
as int,lastRead: freezed == lastRead ? _self.lastRead : lastRead // ignore: cast_nullable_to_non_nullable
as DateTime?,book: freezed == book ? _self.book : book // ignore: cast_nullable_to_non_nullable
as BookModel?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReadingProgressModel].
extension ReadingProgressModelPatterns on ReadingProgressModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReadingProgressModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReadingProgressModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReadingProgressModel value)  $default,){
final _that = this;
switch (_that) {
case _ReadingProgressModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReadingProgressModel value)?  $default,){
final _that = this;
switch (_that) {
case _ReadingProgressModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String bookId,  int currentPage,  int totalReadingTimeInSeconds,  DateTime? lastRead,  BookModel? book)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReadingProgressModel() when $default != null:
return $default(_that.bookId,_that.currentPage,_that.totalReadingTimeInSeconds,_that.lastRead,_that.book);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String bookId,  int currentPage,  int totalReadingTimeInSeconds,  DateTime? lastRead,  BookModel? book)  $default,) {final _that = this;
switch (_that) {
case _ReadingProgressModel():
return $default(_that.bookId,_that.currentPage,_that.totalReadingTimeInSeconds,_that.lastRead,_that.book);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String bookId,  int currentPage,  int totalReadingTimeInSeconds,  DateTime? lastRead,  BookModel? book)?  $default,) {final _that = this;
switch (_that) {
case _ReadingProgressModel() when $default != null:
return $default(_that.bookId,_that.currentPage,_that.totalReadingTimeInSeconds,_that.lastRead,_that.book);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReadingProgressModel implements ReadingProgressModel {
  const _ReadingProgressModel({required this.bookId, required this.currentPage, this.totalReadingTimeInSeconds = 0, this.lastRead, this.book});
  factory _ReadingProgressModel.fromJson(Map<String, dynamic> json) => _$ReadingProgressModelFromJson(json);

@override final  String bookId;
@override final  int currentPage;
@override@JsonKey() final  int totalReadingTimeInSeconds;
@override final  DateTime? lastRead;
@override final  BookModel? book;

/// Create a copy of ReadingProgressModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReadingProgressModelCopyWith<_ReadingProgressModel> get copyWith => __$ReadingProgressModelCopyWithImpl<_ReadingProgressModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReadingProgressModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReadingProgressModel&&(identical(other.bookId, bookId) || other.bookId == bookId)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.totalReadingTimeInSeconds, totalReadingTimeInSeconds) || other.totalReadingTimeInSeconds == totalReadingTimeInSeconds)&&(identical(other.lastRead, lastRead) || other.lastRead == lastRead)&&const DeepCollectionEquality().equals(other.book, book));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bookId,currentPage,totalReadingTimeInSeconds,lastRead,const DeepCollectionEquality().hash(book));

@override
String toString() {
  return 'ReadingProgressModel(bookId: $bookId, currentPage: $currentPage, totalReadingTimeInSeconds: $totalReadingTimeInSeconds, lastRead: $lastRead, book: $book)';
}


}

/// @nodoc
abstract mixin class _$ReadingProgressModelCopyWith<$Res> implements $ReadingProgressModelCopyWith<$Res> {
  factory _$ReadingProgressModelCopyWith(_ReadingProgressModel value, $Res Function(_ReadingProgressModel) _then) = __$ReadingProgressModelCopyWithImpl;
@override @useResult
$Res call({
 String bookId, int currentPage, int totalReadingTimeInSeconds, DateTime? lastRead, BookModel? book
});




}
/// @nodoc
class __$ReadingProgressModelCopyWithImpl<$Res>
    implements _$ReadingProgressModelCopyWith<$Res> {
  __$ReadingProgressModelCopyWithImpl(this._self, this._then);

  final _ReadingProgressModel _self;
  final $Res Function(_ReadingProgressModel) _then;

/// Create a copy of ReadingProgressModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bookId = null,Object? currentPage = null,Object? totalReadingTimeInSeconds = null,Object? lastRead = freezed,Object? book = freezed,}) {
  return _then(_ReadingProgressModel(
bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as String,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,totalReadingTimeInSeconds: null == totalReadingTimeInSeconds ? _self.totalReadingTimeInSeconds : totalReadingTimeInSeconds // ignore: cast_nullable_to_non_nullable
as int,lastRead: freezed == lastRead ? _self.lastRead : lastRead // ignore: cast_nullable_to_non_nullable
as DateTime?,book: freezed == book ? _self.book : book // ignore: cast_nullable_to_non_nullable
as BookModel?,
  ));
}


}

// dart format on
