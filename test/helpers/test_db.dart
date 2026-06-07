import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:book_verse/core/database/database_constants.dart';

bool _ffiInitialized = false;

void _ensureFfi() {
  if (_ffiInitialized) return;
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  _ffiInitialized = true;
}

Future<Database> openTestDb() async {
  _ensureFfi();
  return await databaseFactory.openDatabase(inMemoryDatabasePath,
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
            lastRead TEXT,
            userPageCount INTEGER
          )
        ''');
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
        await db.execute('''
          CREATE TABLE IF NOT EXISTS $libraryFoldersTable (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            icon TEXT DEFAULT 'folder',
            sort_order INTEGER DEFAULT 0,
            created_at TEXT NOT NULL
          )
        ''');
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
      },
    ),
  );
}
