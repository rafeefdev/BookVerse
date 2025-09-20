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
}
