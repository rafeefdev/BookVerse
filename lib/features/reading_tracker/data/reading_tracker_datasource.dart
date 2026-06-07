import 'dart:developer';
import 'package:book_verse/core/database/database_constants.dart';
import 'package:book_verse/core/database/database_provider.dart';
import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';
import 'package:book_verse/features/reading_tracker/model/reading_session_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

final readingTrackerDatasourceProvider =
    Provider<ReadingTrackerDatasource>((ref) {
  return ReadingTrackerDatasource(ref.watch(databaseProvider));
});

class ReadingTrackerDatasource {
  final Database _db;

  ReadingTrackerDatasource(this._db);

  Future<void> saveReadingProgress(ReadingProgressModel progress) async {
    await _db.insert(
      readingProgressTable,
      progress.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<ReadingProgressModel?> getReadingProgress(String bookId) async {
    try {
      final maps = await _db.query(
        readingProgressTable,
        where: 'bookId = ?',
        whereArgs: [bookId],
      );
      if (maps.isNotEmpty) return ReadingProgressModel.fromJson(maps.first);
      return null;
    } catch (e, stack) {
      log('getReadingProgress error: $e\n$stack');
      return null;
    }
  }

  Future<List<ReadingProgressModel>> getAllReadingProgress() async {
    try {
      final maps = await _db.query(readingProgressTable);
      return maps.map((json) => ReadingProgressModel.fromJson(json)).toList();
    } catch (e, stack) {
      log('getAllReadingProgress error: $e\n$stack');
      return [];
    }
  }

  Future<void> deleteReadingProgress(String bookId) async {
    try {
      await _db.delete(
        readingProgressTable,
        where: 'bookId = ?',
        whereArgs: [bookId],
      );
    } catch (e, stack) {
      log('deleteReadingProgress error: $e\n$stack');
    }
  }

  Future<void> saveReadingSession(ReadingSessionModel session) async {
    try {
      await _db.insert(readingSessionsTable, session.toJson());
    } catch (e, stack) {
      log('saveReadingSession error: $e\n$stack');
    }
  }

  Future<List<ReadingSessionModel>> getReadingSessions(String bookId) async {
    try {
      final maps = await _db.query(
        readingSessionsTable,
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
      final maps = await _db.query(
        readingSessionsTable,
        orderBy: 'timestamp DESC',
      );
      return maps.map((json) => ReadingSessionModel.fromJson(json)).toList();
    } catch (e, stack) {
      log('getAllReadingSessions error: $e\n$stack');
      return [];
    }
  }

  Future<void> deleteReadingSessions(String bookId) async {
    try {
      await _db.delete(
        readingSessionsTable,
        where: 'bookId = ?',
        whereArgs: [bookId],
      );
    } catch (e, stack) {
      log('deleteReadingSessions error: $e\n$stack');
    }
  }

  Future<void> updateUserPageCount(String bookId, int userPageCount) async {
    try {
      await _db.update(
        readingProgressTable,
        {'userPageCount': userPageCount},
        where: 'bookId = ?',
        whereArgs: [bookId],
      );
    } catch (e, stack) {
      log('updateUserPageCount error: $e\n$stack');
    }
  }

  Future<void> replaceAll(
    List<ReadingProgressModel> progressList,
    List<ReadingSessionModel> sessionsList,
  ) async {
    await _db.transaction((txn) async {
      await txn.delete(readingProgressTable);
      await txn.delete(readingSessionsTable);
      for (final progress in progressList) {
        await txn.insert(readingProgressTable, progress.toJson());
      }
      for (final session in sessionsList) {
        await txn.insert(readingSessionsTable, session.toJson());
      }
    });
  }

  Future<Map<String, dynamic>?> getBookmark(String bookId) async {
    try {
      final maps = await _db.query(
        bookmarksTable,
        where: 'id = ?',
        whereArgs: [bookId],
      );
      return maps.isNotEmpty ? maps.first : null;
    } catch (e, stack) {
      log('getBookmark error: $e\n$stack');
      return null;
    }
  }
}
