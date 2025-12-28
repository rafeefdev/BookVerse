import 'dart:io';
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
