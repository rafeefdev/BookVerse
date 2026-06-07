import 'dart:developer';
import 'package:book_verse/core/database/database_constants.dart';
import 'package:book_verse/core/database/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

final bookmarkDatasourceProvider = Provider<BookmarkDatasource>((ref) {
  return BookmarkDatasource(ref.watch(databaseProvider));
});

class BookmarkDatasource {
  final Database _db;

  BookmarkDatasource(this._db);

  Future<List<Map<String, dynamic>>> getBookmarkedBooks() async {
    try {
      return _db.query(bookmarksTable);
    } catch (e, stack) {
      log('getBookmarkedBooks error: $e\n$stack');
      return [];
    }
  }

  Future<void> addToBookmark(Map<String, dynamic> book) async {
    try {
      await _db.insert(
        bookmarksTable,
        book,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e, stack) {
      log('addToBookmark error: $e\n$stack');
      rethrow;
    }
  }

  Future<void> removeBookmark(String id) async {
    try {
      await _db.delete(bookmarksTable, where: 'id = ?', whereArgs: [id]);
    } catch (e, stack) {
      log('removeBookmark error: $e\n$stack');
      rethrow;
    }
  }

  Future<bool> isBookmarked(String id) async {
    try {
      final result = await _db.rawQuery(
        'SELECT EXISTS(SELECT 1 FROM $bookmarksTable WHERE id = ?) AS is_exist',
        [id],
      );
      return result.isNotEmpty && result.first['is_exist'] == 1;
    } catch (e, stack) {
      log('isBookmarked error: $e\n$stack');
      return false;
    }
  }
}
