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
    try {
      final progress = await _sqfliteService.getReadingProgress(bookId);
      if (progress != null) {
        final bookData = await _sqfliteService.database.then(
          (db) => db.query('bookmarks', where: 'id = ?', whereArgs: [bookId]),
        );
        if (bookData.isNotEmpty) {
          try {
            final book = Book.fromJson(bookData.first);
            return progress.copyWith(book: book);
          } catch (e) {
            log('Failed to parse book data for $bookId: $e');
          }
        }
      }
      return progress;
    } catch (e, stack) {
      log('ReadingTrackerNotifier.build error: $e\n$stack');
      rethrow;
    }
  }

  Future<void> updateReadingProgress(
    int newCurrentPage, {
    int? durationInSeconds,
  }) async {
    try {
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
    } catch (e, stack) {
      log('updateReadingProgress error: $e\n$stack');
      rethrow;
    }
  }

  Future<void> addReadingSession(ReadingSessionModel session) async {
    try {
      await _sqfliteService.saveReadingSession(session);
      log(
        'Reading session saved for book ${session.bookId}: ${session.durationInSeconds} seconds, ended on page ${session.endPage}',
      );
    } catch (e, stack) {
      log('addReadingSession error: $e\n$stack');
      rethrow;
    }
  }
}

@Riverpod(keepAlive: true)
Future<List<ReadingSessionModel>> bookReadingSessions(
  Ref ref,
  String bookId,
) async {
  try {
    return SqfliteService.instance.getReadingSessions(bookId);
  } catch (e, stack) {
    log('bookReadingSessions error: $e\n$stack');
    return [];
  }
}
