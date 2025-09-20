import 'package:book_verse/core/services/sqflite_service.dart';
import 'package:sqflite/sqflite.dart';

class LocalBookmarkService {
  static final bookMarkTableName = 'bookmarks';
  Future<void> createBookmarkTable() async {
    final db = await SqfliteService.instance.database;
    db.execute('''
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
  }

  Future<void> addToBookmark(Map<String, dynamic> book) async {
    final db = await SqfliteService.instance.database;
    db.insert(
      bookMarkTableName,
      book,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeBookmark(String id) async {
    final db = await SqfliteService.instance.database;
    db.delete(bookMarkTableName, where: 'id = ?', whereArgs: [id]);
  }
}
