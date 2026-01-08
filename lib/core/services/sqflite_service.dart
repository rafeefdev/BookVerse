import 'dart:io';
import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';
import 'package:book_verse/features/reading_tracker/model/reading_session_model.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SqfliteService {
  static final SqfliteService instance = SqfliteService._init();
  static Database? _database;

  SqfliteService._init();

  /// Getter database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase('bookverse.db');
    return _database!;
  }

  /// Inisialisasi database sesuai platform
  Future<Database> _initDatabase(String dbName) async {
    if (Platform.isAndroid || Platform.isIOS) {
      // Mobile pakai sqflite biasa
      final dbPath = await getDatabasesPath();
      final fullPath = join(dbPath, dbName);
      return await openDatabase(fullPath, version: 1, onCreate: _onCreate);
    } else {
      // Desktop pakai sqflite_common_ffi
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;

      final dbPath = await databaseFactory.getDatabasesPath();
      final fullPath = join(dbPath, dbName);
      return await databaseFactory.openDatabase(
        fullPath,
        options: OpenDatabaseOptions(version: 1, onCreate: _onCreate),
      );
    }
  }

  /// Buat tabel awal
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
  }

  Future<void> saveReadingProgress(ReadingProgressModel progress) async {
    final db = await database;
    await db.insert(
      'reading_progress',
      progress.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<ReadingProgressModel?> getReadingProgress(String bookId) async {
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
  }

  Future<List<ReadingProgressModel>> getAllReadingProgress() async {
    final db = await database;
    final maps = await db.query('reading_progress');
    return maps.map((json) => ReadingProgressModel.fromJson(json)).toList();
  }

  Future<void> deleteReadingProgress(String bookId) async {
    final db = await database;
    await db.delete(
      'reading_progress',
      where: 'bookId = ?',
      whereArgs: [bookId],
    );
  }

  Future<void> saveReadingSession(ReadingSessionModel session) async {
    final db = await database;
    await db.insert('reading_sessions', session.toJson());
  }

  Future<List<ReadingSessionModel>> getReadingSessions(String bookId) async {
    final db = await database;
    final maps = await db.query(
      'reading_sessions',
      where: 'bookId = ?',
      whereArgs: [bookId],
      orderBy: 'timestamp DESC',
    );
    return maps.map((json) => ReadingSessionModel.fromJson(json)).toList();
  }

  /// Mengecek apakah tabel ada
  Future<bool> isTableExists(String tableName) async {
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

    // result = [{table_exists: 1}] atau [{table_exists: 0}]
    final value = result.first['table_exists'] as int;
    return value == 1;
  }
}
