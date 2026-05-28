import 'dart:developer';
import 'dart:io';
import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';
import 'package:book_verse/features/reading_tracker/model/reading_session_model.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SqfliteService {
  static final SqfliteService instance = SqfliteService._init();
  static Database? _database;

  SqfliteService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase('bookverse.db');
    return _database!;
  }

  Future<Database> _initDatabase(String dbName) async {
    if (Platform.isAndroid || Platform.isIOS) {
      final dbPath = await getDatabasesPath();
      final fullPath = join(dbPath, dbName);
      return await openDatabase(
        fullPath,
        version: 3,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
      );
    } else {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;

      final dbPath = await databaseFactory.getDatabasesPath();
      final fullPath = join(dbPath, dbName);
      return await databaseFactory.openDatabase(
        fullPath,
        options: OpenDatabaseOptions(
          version: 3,
          onCreate: _onCreate,
          onUpgrade: _onUpgrade,
          onConfigure: (db) async {
            await db.execute('PRAGMA foreign_keys = ON');
          },
        ),
      );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS bookmarks (
        id TEXT PRIMARY KEY,
        title TEXT,
        authors TEXT,
        description TEXT,
        thumbnail TEXT,
        publishedDate TEXT,
        pageCount INTEGER,
        categories TEXT,
        publisher TEXT,
        subTitle TEXT,
        isFavorite INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS reading_progress (
        bookId TEXT PRIMARY KEY,
        currentPage INTEGER,
        totalReadingTimeInSeconds INTEGER,
        lastRead TEXT,
        userPageCount INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS reading_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bookId TEXT,
        durationInSeconds INTEGER,
        endPage INTEGER,
        timestamp TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS library_folders (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT DEFAULT 'folder',
        sort_order INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS library_folder_books (
        folder_id TEXT NOT NULL,
        book_id TEXT NOT NULL,
        added_at TEXT NOT NULL,
        PRIMARY KEY (folder_id, book_id),
        FOREIGN KEY (folder_id) REFERENCES library_folders(id) ON DELETE CASCADE,
        FOREIGN KEY (book_id) REFERENCES bookmarks(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS bookmarks (
        id TEXT PRIMARY KEY,
        title TEXT,
        authors TEXT,
        description TEXT,
        thumbnail TEXT,
        publishedDate TEXT,
        pageCount INTEGER,
        categories TEXT,
        publisher TEXT,
        subTitle TEXT,
        isFavorite INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS reading_progress (
        bookId TEXT PRIMARY KEY,
        currentPage INTEGER,
        totalReadingTimeInSeconds INTEGER,
        lastRead TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS reading_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bookId TEXT,
        durationInSeconds INTEGER,
        endPage INTEGER,
        timestamp TEXT
      )
    ''');

    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS library_folders (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          icon TEXT DEFAULT 'folder',
          sort_order INTEGER DEFAULT 0,
          created_at TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS library_folder_books (
          folder_id TEXT NOT NULL,
          book_id TEXT NOT NULL,
          added_at TEXT NOT NULL,
          PRIMARY KEY (folder_id, book_id),
          FOREIGN KEY (folder_id) REFERENCES library_folders(id) ON DELETE CASCADE,
          FOREIGN KEY (book_id) REFERENCES bookmarks(id) ON DELETE CASCADE
        )
      ''');
    }

    if (oldVersion < 3) {
      try {
        await db.execute(
          'ALTER TABLE reading_progress ADD COLUMN userPageCount INTEGER',
        );
      } catch (e) {
        log('Migration v3: column may already exist — $e');
      }
    }
  }

  Future<void> saveReadingProgress(ReadingProgressModel progress) async {
    try {
      final db = await database;
      await db.insert(
        'reading_progress',
        progress.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e, stack) {
      log('saveReadingProgress error: $e\n$stack');
    }
  }

  Future<ReadingProgressModel?> getReadingProgress(String bookId) async {
    try {
      final db = await database;
      final maps = await db.query(
        'reading_progress',
        where: 'bookId = ?',
        whereArgs: [bookId],
      );

      if (maps.isNotEmpty) {
        return ReadingProgressModel.fromJson(maps.first);
      }
      return null;
    } catch (e, stack) {
      log('getReadingProgress error: $e\n$stack');
      return null;
    }
  }

  Future<List<ReadingProgressModel>> getAllReadingProgress() async {
    try {
      final db = await database;
      final maps = await db.query('reading_progress');
      return maps.map((json) => ReadingProgressModel.fromJson(json)).toList();
    } catch (e, stack) {
      log('getAllReadingProgress error: $e\n$stack');
      return [];
    }
  }

  Future<void> deleteReadingProgress(String bookId) async {
    try {
      final db = await database;
      await db.delete(
        'reading_progress',
        where: 'bookId = ?',
        whereArgs: [bookId],
      );
    } catch (e, stack) {
      log('deleteReadingProgress error: $e\n$stack');
    }
  }

  Future<void> saveReadingSession(ReadingSessionModel session) async {
    try {
      final db = await database;
      await db.insert('reading_sessions', session.toJson());
    } catch (e, stack) {
      log('saveReadingSession error: $e\n$stack');
    }
  }

  Future<List<ReadingSessionModel>> getReadingSessions(String bookId) async {
    try {
      final db = await database;
      final maps = await db.query(
        'reading_sessions',
        where: 'bookId = ?',
        whereArgs: [bookId],
        orderBy: 'timestamp DESC',
      );
      return maps.map((json) => ReadingSessionModel.fromJson(json)).toList();
    } catch (e, stack) {
      log('getReadingSessions error: $e\n$stack');
      return [];
    }
  }

  Future<List<ReadingSessionModel>> getAllReadingSessions() async {
    try {
      final db = await database;
      final maps = await db.query(
        'reading_sessions',
        orderBy: 'timestamp DESC',
      );
      return maps.map((json) => ReadingSessionModel.fromJson(json)).toList();
    } catch (e, stack) {
      log('getAllReadingSessions error: $e\n$stack');
      return [];
    }
  }

  Future<void> updateUserPageCount(String bookId, int userPageCount) async {
    try {
      final db = await database;
      await db.update(
        'reading_progress',
        {'userPageCount': userPageCount},
        where: 'bookId = ?',
        whereArgs: [bookId],
      );
    } catch (e, stack) {
      log('updateUserPageCount error: $e\n$stack');
    }
  }

  Future<bool> isTableExists(String tableName) async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        '''
          SELECT
            CASE
              WHEN EXISTS (
                SELECT 1
                FROM sqlite_master
                WHERE type='table' AND name=?
              )
              THEN 1
              ELSE 0
            END AS table_exists
        ''',
        [tableName],
      );

      final value = result.first['table_exists'] as int;
      return value == 1;
    } catch (e, stack) {
      log('isTableExists error: $e\n$stack');
      return false;
    }
  }
}
