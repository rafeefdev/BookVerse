import 'package:book_verse/core/models/book_model.dart';
import 'package:book_verse/features/bookmarks/model/bookmark_repo.dart';
import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_providers.dart';

void main() {
  late MockBookmarkDatasource mockBookmark;
  late MockReadingTrackerDatasource mockTracker;
  late BookmarkRepo repo;

  setUp(() {
    mockBookmark = MockBookmarkDatasource();
    mockTracker = MockReadingTrackerDatasource();
    repo = BookmarkRepo(
      bookmarkDatasource: mockBookmark,
      readingTrackerDatasource: mockTracker,
    );
  });

  group('BookmarkRepo', () {
    group('getReadingProgressWithBooks', () {
      test('returns empty list when no bookmarks', () async {
        when(() => mockBookmark.getBookmarkedBooks())
            .thenAnswer((_) async => []);
        when(() => mockTracker.getAllReadingProgress())
            .thenAnswer((_) async => []);

        final result = await repo.getReadingProgressWithBooks();

        expect(result, isEmpty);
      });

      test('filters out progress for non-bookmarked books', () async {
        when(() => mockBookmark.getBookmarkedBooks()).thenAnswer(
          (_) async => [
            {
              'id': 'b1',
              'title': 'Book 1',
              'authors': '["Author"]',
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
            ReadingProgressModel(bookId: 'b2', currentPage: 20),
          ],
        );

        final result = await repo.getReadingProgressWithBooks();

        expect(result, hasLength(1));
        expect(result.first.bookId, 'b1');
      });

      test('attaches book to progress', () async {
        when(() => mockBookmark.getBookmarkedBooks()).thenAnswer(
          (_) async => [
            {
              'id': 'b1',
              'title': 'Test Book',
              'authors': '["Author"]',
              'publisher': '',
              'publishedDate': '',
              'description': '',
              'thumbnail': '',
              'pageCount': 200,
              'categories': '',
            },
          ],
        );
        when(() => mockTracker.getAllReadingProgress()).thenAnswer(
          (_) async => [
            ReadingProgressModel(bookId: 'b1', currentPage: 50),
          ],
        );

        final result = await repo.getReadingProgressWithBooks();

        expect(result, hasLength(1));
        expect(result.first.book?.title, 'Test Book');
        expect(result.first.book?.pageCount, 200);
      });
    });

    group('isBookmarked', () {
      test('returns true when reading progress exists', () async {
        when(() => mockTracker.getReadingProgress('b1'))
            .thenAnswer((_) async => ReadingProgressModel(
                  bookId: 'b1',
                  currentPage: 10,
                ));

        final result = await repo.isBookmarked('b1');

        expect(result, true);
      });

      test('returns false when no reading progress', () async {
        when(() => mockTracker.getReadingProgress('b1'))
            .thenAnswer((_) async => null);

        final result = await repo.isBookmarked('b1');

        expect(result, false);
      });
    });

    group('addToBookmark', () {
      test('delegates to addBookmarkWithProgress', () async {
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

        await repo.addToBookmark(book);

        verify(() => mockBookmark.addToBookmark(book.toMap())).called(1);
        verify(() => mockTracker.saveReadingProgress(
          ReadingProgressModel(bookId: 'b1', currentPage: 0),
        )).called(1);
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
