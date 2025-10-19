import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
    final path = await getDatabasesPath();
    final fullPath = join(path, dbName);
    return openDatabase(fullPath, version: 1);
  }

  Future<bool> isTableExists(String tableName) async {
    final db = await SqfliteService.instance.database;
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
