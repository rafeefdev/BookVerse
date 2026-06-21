import 'dart:developer';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'database_constants.dart';

Database? _initializedDb;

Database get db {
  if (_initializedDb == null) throw StateError('Database not initialized');
  return _initializedDb!;
}

final databaseProvider = Provider<Database>((ref) {
  if (_initializedDb == null) throw StateError('Database not initialized');
  return _initializedDb!;
});

Future<Database> initDatabase() async {
  Database db;
  if (Platform.isAndroid || Platform.isIOS) {
    final dbPath = await getDatabasesPath();
    final fullPath = join(dbPath, 'bookverse.db');
    db = await openDatabase(
      fullPath,
      version: 5,
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
    final fullPath = join(dbPath, 'bookverse.db');
    db = await databaseFactory.openDatabase(
      fullPath,
      options: OpenDatabaseOptions(
        version: 5,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
      ),
    );
  }
  _initializedDb = db;
  return db;
}

Future<void> _onCreate(Database db, int version) async {
  await _createBookmarksTable(db);
  await _createReadingProgressTable(db);
  await _createReadingSessionsTable(db);
  await _createLibraryFoldersTable(db);
  await _createLibraryFolderBooksTable(db);
  await _createReadingGoalsTable(db);
}

Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  await _createBookmarksTable(db);
  await _createReadingProgressTableV1(db);
  await _createReadingSessionsTable(db);

  if (oldVersion < 2) {
    await _createLibraryFoldersTable(db);
    await _createLibraryFolderBooksTable(db);
  }

  if (oldVersion < 3) {
    try {
      await db.execute(
        'ALTER TABLE $readingProgressTable ADD COLUMN userPageCount INTEGER',
      );
    } catch (e) {
      log('Migration v3: column may already exist — $e');
    }
  }

  if (oldVersion < 4) {
    try {
      await db.execute(
        'ALTER TABLE $readingSessionsTable ADD COLUMN startPage INTEGER',
      );
    } catch (e) {
      log('Migration v4: column may already exist — $e');
    }
  }

  if (oldVersion < 5) {
    await _createReadingGoalsTable(db);
  }
}

Future<void> _createBookmarksTable(Database db) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS $bookmarksTable (
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
}

Future<void> _createReadingProgressTable(Database db) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS $readingProgressTable (
      bookId TEXT PRIMARY KEY,
      currentPage INTEGER,
      totalReadingTimeInSeconds INTEGER,
      lastRead TEXT,
      userPageCount INTEGER
    )
  ''');
}

Future<void> _createReadingProgressTableV1(Database db) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS $readingProgressTable (
      bookId TEXT PRIMARY KEY,
      currentPage INTEGER,
      totalReadingTimeInSeconds INTEGER,
      lastRead TEXT
    )
  ''');
}

Future<void> _createReadingSessionsTable(Database db) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS $readingSessionsTable (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      bookId TEXT,
      durationInSeconds INTEGER,
      endPage INTEGER,
      timestamp TEXT,
      startPage INTEGER
    )
  ''');
}

Future<void> _createLibraryFoldersTable(Database db) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS $libraryFoldersTable (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      icon TEXT DEFAULT 'folder',
      sort_order INTEGER DEFAULT 0,
      created_at TEXT NOT NULL
    )
  ''');
}

Future<void> _createLibraryFolderBooksTable(Database db) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS $libraryFolderBooksTable (
      folder_id TEXT NOT NULL,
      book_id TEXT NOT NULL,
      added_at TEXT NOT NULL,
      PRIMARY KEY (folder_id, book_id),
      FOREIGN KEY (folder_id) REFERENCES $libraryFoldersTable(id) ON DELETE CASCADE,
      FOREIGN KEY (book_id) REFERENCES $bookmarksTable(id) ON DELETE CASCADE
    )
  ''');
}

Future<void> _createReadingGoalsTable(Database db) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS $readingGoalsTable (
      id INTEGER PRIMARY KEY DEFAULT 1 CHECK (id = 1),
      target_pages INTEGER NOT NULL DEFAULT 30,
      target_minutes INTEGER NOT NULL DEFAULT 20,
      enabled INTEGER NOT NULL DEFAULT 1,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''');
}
