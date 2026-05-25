import 'dart:developer';

import 'package:book_verse/core/models/book_model.dart';
import 'package:book_verse/core/services/sqflite_service.dart';
import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';
import 'package:book_verse/features/reading_tracker/model/reading_session_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reading_tracker_viewmodel.g.dart';

@Riverpod(keepAlive: true)
class ReadingTrackerNotifier extends _$ReadingTrackerNotifier {
  final SqfliteService _sqfliteService = SqfliteService.instance;

  @override
  Future<ReadingProgressModel?> build(String bookId) async {
    final progress = await _sqfliteService.getReadingProgress(bookId);
    if (progress != null) {
      // Also fetch the book details from bookmarks if available
      final bookData = await _sqfliteService.database.then(
        (db) => db.query('bookmarks', where: 'id = ?', whereArgs: [bookId]),
      );
      if (bookData.isNotEmpty) {
        final book = Book.fromJson(bookData.first);
        return progress.copyWith(book: book);
      }
    }
    return progress;
  }

  Future<void> updateReadingProgress(
    int newCurrentPage, {
    int? durationInSeconds,
  }) async {
    final currentState = state.value;
    if (currentState == null) return;

    int updatedTotalReadingTime =
        currentState.totalReadingTimeInSeconds + (durationInSeconds ?? 0);

    final updatedProgress = currentState.copyWith(
      currentPage: newCurrentPage,
      totalReadingTimeInSeconds: updatedTotalReadingTime,
      lastRead: DateTime.now(),
    );

    await _sqfliteService.saveReadingProgress(updatedProgress);
    state = AsyncData(updatedProgress);
  }

  Future<void> addReadingSession(ReadingSessionModel session) async {
    await _sqfliteService.saveReadingSession(session);
    log(
      'Reading session saved for book ${session.bookId}: ${session.durationInSeconds} seconds, ended on page ${session.endPage}',
    );
  }
}

@Riverpod(keepAlive: true)
Future<List<ReadingSessionModel>> bookReadingSessions(
  Ref ref,
  String bookId,
) async {
  return SqfliteService.instance.getReadingSessions(bookId);
}

final activeReadingProgressProvider = FutureProvider<ReadingProgressModel?>((
  ref,
) async {
  final sqfliteService = SqfliteService.instance;
  final allProgress = await sqfliteService.getAllReadingProgress();
  if (allProgress.isEmpty) return null;

  allProgress.sort((a, b) {
    if (a.lastRead == null && b.lastRead == null) return 0;
    if (a.lastRead == null) return 1;
    if (b.lastRead == null) return -1;
    return b.lastRead!.compareTo(a.lastRead!);
  });

  final latest = allProgress.first;
  final db = await sqfliteService.database;
  final bookData = await db.query(
    'bookmarks',
    where: 'id = ?',
    whereArgs: [latest.bookId],
  );
  if (bookData.isNotEmpty) {
    final book = Book.fromJson(bookData.first);
    return latest.copyWith(book: book);
  }
  return latest;
});
