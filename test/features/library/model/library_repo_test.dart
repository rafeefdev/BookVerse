import 'package:book_verse/core/models/book_model.dart';
import 'package:book_verse/features/library/model/library_repo.dart';
import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_providers.dart';

void main() {
  late MockBookmarkDatasource mockBookmark;
  late MockReadingTrackerDatasource mockTracker;
  late MockLibraryFolderDatasource mockFolder;
  late LibraryRepo repo;

  setUp(() {
    mockBookmark = MockBookmarkDatasource();
    mockTracker = MockReadingTrackerDatasource();
    mockFolder = MockLibraryFolderDatasource();
    repo = LibraryRepo(
      bookmarkDatasource: mockBookmark,
      libraryFolderDatasource: mockFolder,
      readingTrackerDatasource: mockTracker,
    );
  });

  group('LibraryRepo', () {
    group('getAllProgressWithBooks', () {
      test('returns empty list when no data', () async {
        when(() => mockBookmark.getBookmarkedBooks())
            .thenAnswer((_) async => []);
        when(() => mockTracker.getAllReadingProgress())
            .thenAnswer((_) async => []);

        final result = await repo.getAllProgressWithBooks();

        expect(result, isEmpty);
      });

      test('includes all progress regardless of bookmark status', () async {
        when(() => mockBookmark.getBookmarkedBooks()).thenAnswer(
          (_) async => [
            {
              'id': 'b1',
              'title': 'Book 1',
              'authors': '["A"]',
              'publisher': '',
              'publishedDate': '',
              'description': '',
              'thumbnail': '',
              'pageCount': 100,
              'categories': '',
            },
          ],
        );
        when(() => mockTracker.getAllReadingProgress()).thenAnswer(
          (_) async => [
            ReadingProgressModel(bookId: 'b1', currentPage: 10),
          ],
        );

        final result = await repo.getAllProgressWithBooks();

        expect(result, hasLength(1));
        expect(result.first.bookId, 'b1');
        expect(result.first.book, isNotNull);
      });

      test('assigns Unknown Book for progress without matching bookmark',
          () async {
        when(() => mockBookmark.getBookmarkedBooks())
            .thenAnswer((_) async => []);
        when(() => mockTracker.getAllReadingProgress()).thenAnswer(
          (_) async => [
            ReadingProgressModel(bookId: 'orphan', currentPage: 50),
          ],
        );

        final result = await repo.getAllProgressWithBooks();

        expect(result, hasLength(1));
        expect(result.first.book?.title, 'Unknown Book');
      });
    });

    group('getAllBookmarkedBooks', () {
      test('returns parsed books from datasource', () async {
        when(() => mockBookmark.getBookmarkedBooks()).thenAnswer(
          (_) async => [
            {
              'id': 'b1',
              'title': 'Book 1',
              'authors': '["Author"]',
              'publisher': 'Pub',
              'publishedDate': '2020',
              'description': 'Desc',
              'thumbnail': '',
              'pageCount': 300,
              'categories': '["Fiction"]',
            },
          ],
        );

        final result = await repo.getAllBookmarkedBooks();

        expect(result, hasLength(1));
        expect(result.first.id, 'b1');
        expect(result.first.title, 'Book 1');
      });
    });

    group('saveBook', () {
      test('adds bookmark, progress, and assigns to default folder',
          () async {
        final book = Book(
          id: 'b1',
          title: 'Test',
          subTitle: '',
          authors: [],
          publisher: '',
          publishedDate: '',
          description: '',
          thumbnail: '',
          pageCount: 100,
        );

        when(() => mockBookmark.addToBookmark(book.toMap()))
            .thenAnswer((_) async => {});
        when(() => mockTracker.saveReadingProgress(
          ReadingProgressModel(bookId: 'b1', currentPage: 0),
        )).thenAnswer((_) async => {});
        when(() => mockFolder.assignToDefaultFolder(any()))
            .thenAnswer((_) async => {});

        await repo.saveBook(book);

        verify(() => mockBookmark.addToBookmark(book.toMap())).called(1);
        verify(() => mockTracker.saveReadingProgress(
          ReadingProgressModel(bookId: 'b1', currentPage: 0),
        )).called(1);
        verify(() => mockFolder.assignToDefaultFolder('b1')).called(1);
      });
    });

    group('removeBookmark', () {
      test('delegates to removeBookmarkCascade', () async {
        when(() => mockBookmark.removeBookmark('b1'))
            .thenAnswer((_) async => {});
        when(() => mockTracker.deleteReadingProgress('b1'))
            .thenAnswer((_) async => {});
        when(() => mockTracker.deleteReadingSessions('b1'))
            .thenAnswer((_) async => {});

        await repo.removeBookmark('b1');

        verify(() => mockBookmark.removeBookmark('b1')).called(1);
        verify(() => mockTracker.deleteReadingProgress('b1')).called(1);
        verify(() => mockTracker.deleteReadingSessions('b1')).called(1);
      });
    });
  });
}
