import 'dart:developer';

import 'package:book_verse/core/models/book_model.dart';
import 'package:book_verse/features/reading_tracker/data/reading_tracker_datasource.dart';
import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';
import 'package:book_verse/features/reading_tracker/model/reading_session_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reading_tracker_viewmodel.g.dart';

@Riverpod(keepAlive: true)
class ReadingTrackerNotifier extends _$ReadingTrackerNotifier {
  @override
  Future<ReadingProgressModel?> build(String bookId) async {
    try {
      final datasource = ref.watch(readingTrackerDatasourceProvider);
      final progress = await datasource.getReadingProgress(bookId);
      if (progress != null) {
        final bookData = await datasource.getBookmark(bookId);
        if (bookData != null) {
          try {
            final book = Book.fromJson(bookData);
            return progress.copyWith(book: book);
          } catch (e) {
            log('Failed to parse book data for $bookId: $e');
          }
        }
      }
      return progress;
    } catch (e, stack) {
      log('ReadingTrackerNotifier.build error: $e\n$stack');
      return null;
    }
  }

  Future<void> updateReadingProgress(
    int newCurrentPage, {
    int? durationInSeconds,
    int? userPageCount,
  }) async {
    try {
      final datasource = ref.read(readingTrackerDatasourceProvider);
      var currentState = state.value;
      if (currentState == null) {
        final dbProgress = await datasource.getReadingProgress(bookId);
        if (dbProgress == null) return;
        currentState = dbProgress;
      }

      int updatedTotalReadingTime =
          currentState.totalReadingTimeInSeconds + (durationInSeconds ?? 0);

      final updatedProgress = currentState.copyWith(
        currentPage: newCurrentPage,
        totalReadingTimeInSeconds: updatedTotalReadingTime,
        lastRead: DateTime.now(),
        userPageCount: userPageCount,
      );

      await datasource.saveReadingProgress(updatedProgress);
      state = AsyncData(updatedProgress);
    } catch (e, stack) {
      log('updateReadingProgress error: $e\n$stack');
    }
  }

  Future<void> addReadingSession(ReadingSessionModel session) async {
    try {
      final datasource = ref.read(readingTrackerDatasourceProvider);
      await datasource.saveReadingSession(session);
      log(
        'Reading session saved for book ${session.bookId}: ${session.durationInSeconds} seconds, ended on page ${session.endPage}',
      );
    } catch (e, stack) {
      log('addReadingSession error: $e\n$stack');
    }
  }
}

@Riverpod(keepAlive: true)
Future<List<ReadingSessionModel>> bookReadingSessions(
  Ref ref,
  String bookId,
) async {
  try {
    final datasource = ref.watch(readingTrackerDatasourceProvider);
    return datasource.getReadingSessions(bookId);
  } catch (e, stack) {
    log('bookReadingSessions error: $e\n$stack');
    return [];
  }
}
