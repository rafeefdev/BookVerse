import 'dart:developer';
import 'package:book_verse/core/services/sqflite_service.dart';
import 'package:sqflite/sqflite.dart';

class LocalBookmarkService {
  static final bookMarkTableName = 'bookmarks';

  Future<void> createBookmarkTable() async {
    try {
      final db = await SqfliteService.instance.database;
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $bookMarkTableName (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          subTitle TEXT,
          authors TEXT,        
          pageCount INTEGER,
          publisher TEXT,
          categories TEXT,     
          publishedDate TEXT,
          description TEXT,
          thumbnail TEXT
      );
      ''');
    } catch (e, stack) {
      log('createBookmarkTable error: $e\n$stack');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getBookmarkedBooks() async {
    try {
      final db = await SqfliteService.instance.database;
      bool isTableDefined = await SqfliteService.instance.isTableExists(
        bookMarkTableName,
      );
      return isTableDefined ? db.query(bookMarkTableName) : [];
    } catch (e, stack) {
      log('getBookmarkedBooks error: $e\n$stack');
      return [];
    }
  }

  Future<void> addToBookmark(Map<String, dynamic> book) async {
    try {
      final db = await SqfliteService.instance.database;
      await db.insert(
        bookMarkTableName,
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
      final db = await SqfliteService.instance.database;
      await db.delete(bookMarkTableName, where: 'id = ?', whereArgs: [id]);
    } catch (e, stack) {
      log('removeBookmark error: $e\n$stack');
      rethrow;
    }
  }

  Future<bool> isBookmarked(String id) async {
    try {
      final db = await SqfliteService.instance.database;
      final result = await db.rawQuery(
        '''SELECT EXISTS(
          SELECT 1 FROM $bookMarkTableName WHERE id = ?) AS is_exist''',
        [id],
      );
      return result.isNotEmpty && result.first['is_exist'] == 1;
    } catch (e, stack) {
      log('isBookmarked error: $e\n$stack');
      return false;
    }
  }
}
