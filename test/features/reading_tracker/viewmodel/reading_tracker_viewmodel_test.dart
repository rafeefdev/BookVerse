import 'package:book_verse/core/models/book_model.dart';
import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';
import 'package:book_verse/features/reading_tracker/viewmodel/reading_tracker_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_providers.dart';

void main() {
  registerFallbackValue(ReadingProgressModel(
    bookId: '',
    currentPage: 0,
  ));
  late MockReadingTrackerDatasource mockDatasource;
  late MockBookmarkDatasource mockBookmark;
  late MockLibraryFolderDatasource mockFolder;

  setUp(() {
    mockDatasource = MockReadingTrackerDatasource();
    mockBookmark = MockBookmarkDatasource();
    mockFolder = MockLibraryFolderDatasource();
  });

  ProviderContainer createContainer() {
    return createTestContainer(
      readingTrackerDatasource: mockDatasource,
      bookmarkDatasource: mockBookmark,
      libraryFolderDatasource: mockFolder,
    );
  }

  group('ReadingTrackerNotifier - updateReadingProgress', () {
    test('saves userPageCount when provided', () async {
      final book = Book(
        id: 'b1',
        title: 'Test',
        subTitle: '',
        authors: [],
        publisher: '',
        publishedDate: '',
        description: '',
        thumbnail: '',
        pageCount: 300,
      );

      when(() => mockDatasource.getReadingProgress('b1')).thenAnswer(
        (_) async => ReadingProgressModel(bookId: 'b1', currentPage: 50),
      );
      when(() => mockDatasource.getBookmark('b1')).thenAnswer(
        (_) async => book.toMap(),
      );
      when(
        () => mockDatasource.saveReadingProgress(any<ReadingProgressModel>()),
      ).thenAnswer((_) async => {});

      final container = createContainer();
      final notifier = container.read(
        readingTrackerNotifierProvider('b1').notifier,
      );

      await notifier.updateReadingProgress(200, userPageCount: 350);

      final captured = verify(
        () => mockDatasource.saveReadingProgress(captureAny<ReadingProgressModel>()),
      ).captured.single as ReadingProgressModel;

      expect(captured.currentPage, 200);
      expect(captured.userPageCount, 350);
      expect(captured.effectivePageCount, 350);
    });

    test('preserves existing userPageCount when not provided again', () async {
      final book = Book(
        id: 'b1',
        title: 'Test',
        subTitle: '',
        authors: [],
        publisher: '',
        publishedDate: '',
        description: '',
        thumbnail: '',
        pageCount: 300,
      );

      when(() => mockDatasource.getReadingProgress('b1')).thenAnswer(
        (_) async => ReadingProgressModel(
          bookId: 'b1',
          currentPage: 50,
          userPageCount: 350,
        ),
      );
      when(() => mockDatasource.getBookmark('b1')).thenAnswer(
        (_) async => book.toMap(),
      );
      when(
        () => mockDatasource.saveReadingProgress(any<ReadingProgressModel>()),
      ).thenAnswer((_) async => {});

      final container = createContainer();
      final notifier = container.read(
        readingTrackerNotifierProvider('b1').notifier,
      );

      await notifier.updateReadingProgress(200);

      final captured = verify(
        () => mockDatasource.saveReadingProgress(captureAny<ReadingProgressModel>()),
      ).captured.single as ReadingProgressModel;

      expect(captured.currentPage, 200);
      expect(captured.userPageCount, 350);
    });

    test('updates local state after save', () async {
      final book = Book(
        id: 'b1',
        title: 'Test',
        subTitle: '',
        authors: [],
        publisher: '',
        publishedDate: '',
        description: '',
        thumbnail: '',
        pageCount: 300,
      );

      final initialProgress = ReadingProgressModel(
        bookId: 'b1',
        currentPage: 50,
        book: book,
      );

      when(() => mockDatasource.getReadingProgress('b1'))
          .thenAnswer((_) async => initialProgress);
      when(() => mockDatasource.getBookmark('b1'))
          .thenAnswer((_) async => book.toMap());
      when(
        () => mockDatasource.saveReadingProgress(any<ReadingProgressModel>()),
      ).thenAnswer((_) async => {});

      final container = createContainer();
      await container.read(readingTrackerNotifierProvider('b1').future);

      final notifier = container.read(
        readingTrackerNotifierProvider('b1').notifier,
      );

      await notifier.updateReadingProgress(200, userPageCount: 350);

      final state = container.read(readingTrackerNotifierProvider('b1'));
      expect(state.valueOrNull?.currentPage, 200);
      expect(state.valueOrNull?.userPageCount, 350);
    });

  });
}
