import 'dart:convert';
import 'dart:io';

import 'package:book_verse/core/services/sqflite_service.dart';
import 'package:path_provider/path_provider.dart';

class BackupService {
  static final BackupService instance = BackupService._init();
  BackupService._init();

  Future<String> backupProgress() async {
    final db = SqfliteService.instance;
    final progress = await db.getAllReadingProgress();
    final sessions = await db.getAllReadingSessions();

    final data = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'readingProgress': progress.map((p) => p.toJson()).toList(),
      'readingSessions': sessions.map((s) => s.toJson()).toList(),
    };

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/bookverse_backup.json');
    await file.writeAsString(jsonEncode(data));

    return file.path;
  }
}
