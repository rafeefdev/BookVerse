import 'dart:convert';
import 'dart:io';

import 'package:book_verse/core/database/database_provider.dart';
import 'package:book_verse/features/reading_tracker/data/reading_tracker_datasource.dart';
import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';
import 'package:book_verse/features/reading_tracker/model/reading_session_model.dart';
import 'package:path_provider/path_provider.dart';

enum RestoreErrorCode {
  fileNotFound,
  invalidJson,
  versionMismatch,
  missingData,
  databaseError,
  unknown,
}

class RestoreException implements Exception {
  final RestoreErrorCode code;
  final String message;
  final String detail;

  const RestoreException({
    required this.code,
    required this.message,
    this.detail = '',
  });

  @override
  String toString() => message;
}

class RestoreResult {
  final int progressCount;
  final int sessionsCount;
  final String snapshotPath;

  const RestoreResult({
    required this.progressCount,
    required this.sessionsCount,
    required this.snapshotPath,
  });
}

class BackupService {
  static final BackupService instance = BackupService._init();
  final ReadingTrackerDatasource _datasource;

  BackupService._init() : _datasource = ReadingTrackerDatasource(db);

  BackupService.withDatasource(this._datasource);

  Future<String> backupProgress() async {
    final progress = await _datasource.getAllReadingProgress();
    final sessions = await _datasource.getAllReadingSessions();

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

  Future<bool> hasBackup() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/bookverse_backup.json').exists();
  }

  Future<RestoreResult> restoreProgress() async {
    final dir = await getApplicationDocumentsDirectory();
    final backupFile = File('${dir.path}/bookverse_backup.json');

    if (!await backupFile.exists()) {
      throw RestoreException(
        code: RestoreErrorCode.fileNotFound,
        message: 'No backup file found.',
        detail: 'Create a backup first in Settings > Data.',
      );
    }

    final currentProgress = await _datasource.getAllReadingProgress();
    final currentSessions = await _datasource.getAllReadingSessions();

    final snapshot = {
      'version': 1,
      'backedUpAt': DateTime.now().toIso8601String(),
      'readingProgress': currentProgress.map((p) => p.toJson()).toList(),
      'readingSessions': currentSessions.map((s) => s.toJson()).toList(),
    };
    final snapshotFile = File(
      '${dir.path}/bookverse_autobackup_before_restore.json',
    );
    await snapshotFile.writeAsString(jsonEncode(snapshot));

    Map<String, dynamic> data;
    try {
      final jsonString = await backupFile.readAsString();
      data = jsonDecode(jsonString) as Map<String, dynamic>;
    } on FormatException {
      throw RestoreException(
        code: RestoreErrorCode.invalidJson,
        message: 'The backup file is corrupted.',
        detail: 'The file cannot be read. Create a new backup.',
      );
    } on TypeError {
      throw RestoreException(
        code: RestoreErrorCode.invalidJson,
        message: 'The backup file has an invalid format.',
        detail: 'The file structure is wrong. Create a new backup.',
      );
    }

    if (data['version'] != 1) {
      throw RestoreException(
        code: RestoreErrorCode.versionMismatch,
        message: 'This backup is not compatible with the current app version.',
        detail: 'Update the app or create a new backup.',
      );
    }

    if (data['readingProgress'] == null || data['readingSessions'] == null) {
      throw RestoreException(
        code: RestoreErrorCode.missingData,
        message: 'The backup file is missing essential data.',
        detail: 'Some sections are empty. Create a new backup.',
      );
    }

    List<ReadingProgressModel> progressList;
    List<ReadingSessionModel> sessionsList;
    try {
      progressList = (data['readingProgress'] as List)
          .map((e) => ReadingProgressModel.fromJson(e as Map<String, dynamic>))
          .toList();
      sessionsList = (data['readingSessions'] as List)
          .map((e) => ReadingSessionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw RestoreException(
        code: RestoreErrorCode.missingData,
        message: 'Some records in the backup are corrupted.',
        detail: 'Individual data entries could not be read.',
      );
    }

    await _datasource.replaceAll(progressList, sessionsList);

    return RestoreResult(
      progressCount: progressList.length,
      sessionsCount: sessionsList.length,
      snapshotPath: snapshotFile.path,
    );
  }
}
