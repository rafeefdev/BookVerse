import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:book_verse/features/bookmarks/data/bookmark_datasource.dart';
import '../../../helpers/test_db.dart';

void main() {
  late Database db;
  late BookmarkDatasource datasource;

  setUp(() async {
    db = await openTestDb();
    datasource = BookmarkDatasource(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('BookmarkDatasource', () {
    final book = {
      'id': 'b1',
      'title': 'Test Book',
      'authors': '["Author A"]',
      'isFavorite': 0,
    };

    test('add and list bookmarks', () async {
      await datasource.addToBookmark(book);
      final books = await datasource.getBookmarkedBooks();
      expect(books.length, 1);
      expect(books.first['id'], 'b1');
    });

    test('isBookmarked returns true for bookmarked book', () async {
      await datasource.addToBookmark(book);
      final result = await datasource.isBookmarked('b1');
      expect(result, isTrue);
    });

    test('isBookmarked returns false for non-bookmarked book', () async {
      final result = await datasource.isBookmarked('nonexistent');
      expect(result, isFalse);
    });

    test('remove bookmark', () async {
      await datasource.addToBookmark(book);
      await datasource.removeBookmark('b1');
      final books = await datasource.getBookmarkedBooks();
      expect(books, isEmpty);
    });

    test('addToBookmark replaces existing entry', () async {
      await datasource.addToBookmark(book);
      await datasource.addToBookmark({...book, 'title': 'Updated'});
      final books = await datasource.getBookmarkedBooks();
      expect(books.length, 1);
      expect(books.first['title'], 'Updated');
    });
  });
}
