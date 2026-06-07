import 'package:book_verse/core/database/database_constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'dart:io';

import 'package:path/path.dart' as p;

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Database migration', () {
    late String dbPath;

    setUp(() {
      dbPath = p.join(
        Directory.systemTemp.path,
        'bookverse_test_${DateTime.now().millisecondsSinceEpoch}.db',
      );
    });

    tearDown(() async {
      try {
        await databaseFactory.deleteDatabase(dbPath);
      } catch (_) {}
    });

    test('v1 to v4 adds userPageCount and startPage columns', () async {
      // Create v1 database
      final v1Db = await databaseFactory.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
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
            await db.execute('''
              CREATE TABLE IF NOT EXISTS $readingProgressTable (
                bookId TEXT PRIMARY KEY,
                currentPage INTEGER,
                totalReadingTimeInSeconds INTEGER,
                lastRead TEXT
              )
            ''');
            await db.execute('''
              CREATE TABLE IF NOT EXISTS $readingSessionsTable (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                bookId TEXT,
                durationInSeconds INTEGER,
                endPage INTEGER,
                timestamp TEXT
              )
            ''');
          },
        ),
      );

      // Insert test data into v1
      await v1Db.insert(bookmarksTable, {'id': 'b1', 'title': 'Test Book'});
      await v1Db.insert(readingProgressTable, {
        'bookId': 'b1',
        'currentPage': 50,
        'totalReadingTimeInSeconds': 3600,
        'lastRead': '2025-01-01T00:00:00.000',
      });
      await v1Db.insert(readingSessionsTable, {
        'bookId': 'b1',
        'durationInSeconds': 600,
        'endPage': 30,
        'timestamp': '2025-01-01T00:00:00.000',
      });

      await v1Db.close();

      // Reopen at version 4 — triggers onUpgrade
      final v4Db = await databaseFactory.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(
          version: 4,
          onCreate: (db, version) async {
            await db.execute('''
              CREATE TABLE IF NOT EXISTS $bookmarksTable (
                id TEXT PRIMARY KEY, title TEXT, authors TEXT,
                description TEXT, thumbnail TEXT, publishedDate TEXT,
                pageCount INTEGER, categories TEXT, publisher TEXT,
                subTitle TEXT, isFavorite INTEGER
              )
            ''');
            await db.execute('''
              CREATE TABLE IF NOT EXISTS $readingProgressTable (
                bookId TEXT PRIMARY KEY, currentPage INTEGER,
                totalReadingTimeInSeconds INTEGER, lastRead TEXT,
                userPageCount INTEGER
              )
            ''');
            await db.execute('''
              CREATE TABLE IF NOT EXISTS $readingSessionsTable (
                id INTEGER PRIMARY KEY AUTOINCREMENT, bookId TEXT,
                durationInSeconds INTEGER, endPage INTEGER,
                timestamp TEXT, startPage INTEGER
              )
            ''');
            await _createLibraryFoldersTable(db);
            await _createLibraryFolderBooksTable(db);
          },
          onUpgrade: (db, oldVersion, newVersion) async {
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
              } catch (_) {}
            }

            if (oldVersion < 4) {
              try {
                await db.execute(
                  'ALTER TABLE $readingSessionsTable ADD COLUMN startPage INTEGER',
                );
              } catch (_) {}
            }
          },
        ),
      );

      // Verify v4 schema: userPageCount and startPage columns exist
      final progressColumns = await v4Db.rawQuery(
        'PRAGMA table_info($readingProgressTable)',
      );
      final progressNames =
          progressColumns.map((c) => c['name'] as String).toSet();
      expect(progressNames, contains('userPageCount'));

      final sessionColumns = await v4Db.rawQuery(
        'PRAGMA table_info($readingSessionsTable)',
      );
      final sessionNames =
          sessionColumns.map((c) => c['name'] as String).toSet();
      expect(sessionNames, contains('startPage'));

      // Verify v4 has all tables
      final tables = await v4Db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'",
      );
      final tableNames = tables.map((t) => t['name'] as String).toSet();
      expect(tableNames, contains(bookmarksTable));
      expect(tableNames, contains(readingProgressTable));
      expect(tableNames, contains(readingSessionsTable));
      expect(tableNames, contains(libraryFoldersTable));
      expect(tableNames, contains(libraryFolderBooksTable));

      // Verify v1 data is preserved
      final progressRows = await v4Db.query(
        readingProgressTable,
        where: 'bookId = ?',
        whereArgs: ['b1'],
      );
      expect(progressRows, hasLength(1));
      expect(progressRows.first['currentPage'], 50);

      final sessionRows = await v4Db.query(
        readingSessionsTable,
        where: 'bookId = ?',
        whereArgs: ['b1'],
      );
      expect(sessionRows, hasLength(1));
      expect(sessionRows.first['durationInSeconds'], 600);

      await v4Db.close();
    });
  });
}

Future<void> _createBookmarksTable(Database db) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS $bookmarksTable (
      id TEXT PRIMARY KEY, title TEXT, authors TEXT,
      description TEXT, thumbnail TEXT, publishedDate TEXT,
      pageCount INTEGER, categories TEXT, publisher TEXT,
      subTitle TEXT, isFavorite INTEGER
    )
  ''');
}

Future<void> _createReadingProgressTableV1(Database db) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS $readingProgressTable (
      bookId TEXT PRIMARY KEY, currentPage INTEGER,
      totalReadingTimeInSeconds INTEGER, lastRead TEXT
    )
  ''');
}

Future<void> _createReadingSessionsTable(Database db) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS $readingSessionsTable (
      id INTEGER PRIMARY KEY AUTOINCREMENT, bookId TEXT,
      durationInSeconds INTEGER, endPage INTEGER,
      timestamp TEXT, startPage INTEGER
    )
  ''');
}

Future<void> _createLibraryFoldersTable(Database db) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS $libraryFoldersTable (
      id TEXT PRIMARY KEY, name TEXT NOT NULL,
      icon TEXT DEFAULT 'folder', sort_order INTEGER DEFAULT 0,
      created_at TEXT NOT NULL
    )
  ''');
}

Future<void> _createLibraryFolderBooksTable(Database db) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS $libraryFolderBooksTable (
      folder_id TEXT NOT NULL, book_id TEXT NOT NULL,
      added_at TEXT NOT NULL,
      PRIMARY KEY (folder_id, book_id),
      FOREIGN KEY (folder_id) REFERENCES $libraryFoldersTable(id) ON DELETE CASCADE,
      FOREIGN KEY (book_id) REFERENCES $bookmarksTable(id) ON DELETE CASCADE
    )
  ''');
}
