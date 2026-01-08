// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_tracker_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bookReadingSessionsHash() =>
    r'c2adc39c5c3ec9e4583487f353371568bce5bead';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [bookReadingSessions].
@ProviderFor(bookReadingSessions)
const bookReadingSessionsProvider = BookReadingSessionsFamily();

/// See also [bookReadingSessions].
class BookReadingSessionsFamily
    extends Family<AsyncValue<List<ReadingSessionModel>>> {
  /// See also [bookReadingSessions].
  const BookReadingSessionsFamily();

  /// See also [bookReadingSessions].
  BookReadingSessionsProvider call(String bookId) {
    return BookReadingSessionsProvider(bookId);
  }

  @override
  BookReadingSessionsProvider getProviderOverride(
    covariant BookReadingSessionsProvider provider,
  ) {
    return call(provider.bookId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'bookReadingSessionsProvider';
}

/// See also [bookReadingSessions].
class BookReadingSessionsProvider
    extends FutureProvider<List<ReadingSessionModel>> {
  /// See also [bookReadingSessions].
  BookReadingSessionsProvider(String bookId)
    : this._internal(
        (ref) => bookReadingSessions(ref as BookReadingSessionsRef, bookId),
        from: bookReadingSessionsProvider,
        name: r'bookReadingSessionsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$bookReadingSessionsHash,
        dependencies: BookReadingSessionsFamily._dependencies,
        allTransitiveDependencies:
            BookReadingSessionsFamily._allTransitiveDependencies,
        bookId: bookId,
      );

  BookReadingSessionsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.bookId,
  }) : super.internal();

  final String bookId;

  @override
  Override overrideWith(
    FutureOr<List<ReadingSessionModel>> Function(
      BookReadingSessionsRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BookReadingSessionsProvider._internal(
        (ref) => create(ref as BookReadingSessionsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        bookId: bookId,
      ),
    );
  }

  @override
  FutureProviderElement<List<ReadingSessionModel>> createElement() {
    return _BookReadingSessionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BookReadingSessionsProvider && other.bookId == bookId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, bookId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin BookReadingSessionsRef on FutureProviderRef<List<ReadingSessionModel>> {
  /// The parameter `bookId` of this provider.
  String get bookId;
}

class _BookReadingSessionsProviderElement
    extends FutureProviderElement<List<ReadingSessionModel>>
    with BookReadingSessionsRef {
  _BookReadingSessionsProviderElement(super.provider);

  @override
  String get bookId => (origin as BookReadingSessionsProvider).bookId;
}

String _$readingTrackerNotifierHash() =>
    r'057c297403ea7444bead08dd789a6381439ee3b8';

abstract class _$ReadingTrackerNotifier
    extends BuildlessAsyncNotifier<ReadingProgressModel?> {
  late final String bookId;

  FutureOr<ReadingProgressModel?> build(String bookId);
}

/// See also [ReadingTrackerNotifier].
@ProviderFor(ReadingTrackerNotifier)
const readingTrackerNotifierProvider = ReadingTrackerNotifierFamily();

/// See also [ReadingTrackerNotifier].
class ReadingTrackerNotifierFamily
    extends Family<AsyncValue<ReadingProgressModel?>> {
  /// See also [ReadingTrackerNotifier].
  const ReadingTrackerNotifierFamily();

  /// See also [ReadingTrackerNotifier].
  ReadingTrackerNotifierProvider call(String bookId) {
    return ReadingTrackerNotifierProvider(bookId);
  }

  @override
  ReadingTrackerNotifierProvider getProviderOverride(
    covariant ReadingTrackerNotifierProvider provider,
  ) {
    return call(provider.bookId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'readingTrackerNotifierProvider';
}

/// See also [ReadingTrackerNotifier].
class ReadingTrackerNotifierProvider
    extends
        AsyncNotifierProviderImpl<
          ReadingTrackerNotifier,
          ReadingProgressModel?
        > {
  /// See also [ReadingTrackerNotifier].
  ReadingTrackerNotifierProvider(String bookId)
    : this._internal(
        () => ReadingTrackerNotifier()..bookId = bookId,
        from: readingTrackerNotifierProvider,
        name: r'readingTrackerNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$readingTrackerNotifierHash,
        dependencies: ReadingTrackerNotifierFamily._dependencies,
        allTransitiveDependencies:
            ReadingTrackerNotifierFamily._allTransitiveDependencies,
        bookId: bookId,
      );

  ReadingTrackerNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.bookId,
  }) : super.internal();

  final String bookId;

  @override
  FutureOr<ReadingProgressModel?> runNotifierBuild(
    covariant ReadingTrackerNotifier notifier,
  ) {
    return notifier.build(bookId);
  }

  @override
  Override overrideWith(ReadingTrackerNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: ReadingTrackerNotifierProvider._internal(
        () => create()..bookId = bookId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        bookId: bookId,
      ),
    );
  }

  @override
  AsyncNotifierProviderElement<ReadingTrackerNotifier, ReadingProgressModel?>
  createElement() {
    return _ReadingTrackerNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReadingTrackerNotifierProvider && other.bookId == bookId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, bookId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ReadingTrackerNotifierRef
    on AsyncNotifierProviderRef<ReadingProgressModel?> {
  /// The parameter `bookId` of this provider.
  String get bookId;
}

class _ReadingTrackerNotifierProviderElement
    extends
        AsyncNotifierProviderElement<
          ReadingTrackerNotifier,
          ReadingProgressModel?
        >
    with ReadingTrackerNotifierRef {
  _ReadingTrackerNotifierProviderElement(super.provider);

  @override
  String get bookId => (origin as ReadingTrackerNotifierProvider).bookId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
