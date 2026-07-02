import 'package:book_verse/core/models/book_model.dart';
import 'package:book_verse/core/utils/reading_cleanup_utils.dart';
import 'package:book_verse/features/bookmarks/data/bookmark_datasource.dart';
import 'package:book_verse/features/reading_tracker/data/reading_tracker_datasource.dart';
import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';
import 'package:book_verse/features/reading_tracker/model/reading_session_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common/sqlite_api.dart';

import '../../helpers/test_db.dart';

void main() {
  late Database db;
  late BookmarkDatasource bookmarkDatasource;
  late ReadingTrackerDatasource readingTrackerDatasource;

  setUp(() async {
    db = await openTestDb();
    bookmarkDatasource = BookmarkDatasource(db);
    readingTrackerDatasource = ReadingTrackerDatasource(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('removeBookmarkCascade', () {
    test('removes bookmark, progress, and sessions', () async {
      final book = Book(
        id: 'b1',
        title: 'Test Book',
        authors: ['Author'],
        description: '',
        thumbnail: '',
        publishedDate: '2026',
        pageCount: 200,
        publisher: '',
        subTitle: '',
      );

      await bookmarkDatasource.addToBookmark(book.toMap());
      await readingTrackerDatasource.saveReadingProgress(
        ReadingProgressModel(bookId: 'b1', currentPage: 50),
      );
      await readingTrackerDatasource.saveReadingSession(
        ReadingSessionModel(
          bookId: 'b1',
          durationInSeconds: 600,
          endPage: 30,
          timestamp: DateTime(2026, 6, 7),
        ),
      );

      await removeBookmarkCascade(
        bookmarkDatasource: bookmarkDatasource,
        readingTrackerDatasource: readingTrackerDatasource,
        bookId: 'b1',
      );

      final books = await bookmarkDatasource.getBookmarkedBooks();
      expect(books, isEmpty);

      final progress = await readingTrackerDatasource.getReadingProgress('b1');
      expect(progress, isNull);

      final sessions = await readingTrackerDatasource.getReadingSessions('b1');
      expect(sessions, isEmpty);
    });

    test('does not affect other books', () async {
      final book1 = Book(
        id: 'b1',
        title: 'Book 1',
        authors: [],
        description: '',
        thumbnail: '',
        publishedDate: '',
        pageCount: 100,
        publisher: '',
        subTitle: '',
      );
      final book2 = Book(
        id: 'b2',
        title: 'Book 2',
        authors: [],
        description: '',
        thumbnail: '',
        publishedDate: '',
        pageCount: 200,
        publisher: '',
        subTitle: '',
      );

      await bookmarkDatasource.addToBookmark(book1.toMap());
      await bookmarkDatasource.addToBookmark(book2.toMap());

      await removeBookmarkCascade(
        bookmarkDatasource: bookmarkDatasource,
        readingTrackerDatasource: readingTrackerDatasource,
        bookId: 'b1',
      );

      final books = await bookmarkDatasource.getBookmarkedBooks();
      expect(books.length, 1);
      expect(books.first['id'], 'b2');
    });
  });

  group('addBookmarkWithProgress', () {
    test('creates bookmark and initializes progress', () async {
      final book = Book(
        id: 'b1',
        title: 'New Book',
        authors: ['Author'],
        description: '',
        thumbnail: '',
        publishedDate: '2026',
        pageCount: 300,
        publisher: '',
        subTitle: '',
      );

      await addBookmarkWithProgress(
        bookmarkDatasource: bookmarkDatasource,
        readingTrackerDatasource: readingTrackerDatasource,
        book: book,
      );

      final books = await bookmarkDatasource.getBookmarkedBooks();
      expect(books.length, 1);
      expect(books.first['id'], 'b1');

      final progress = await readingTrackerDatasource.getReadingProgress('b1');
      expect(progress, isNotNull);
      expect(progress!.currentPage, 0);
      expect(progress.bookId, 'b1');
    });
  });
}
