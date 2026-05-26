import 'dart:async';

import 'package:book_verse/core/models/book_model.dart';
import 'package:book_verse/core/services/sqflite_service.dart';
import 'package:book_verse/features/bookmarks/viewmodel/bookmark_viewmodel.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';
import 'package:book_verse/features/reading_tracker/model/reading_session_model.dart';
import 'package:book_verse/features/reading_tracker/viewmodel/reading_tracker_viewmodel.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_recording_viewmodel.g.dart';

@Riverpod(keepAlive: true)
class SessionRecordingNotifier extends _$SessionRecordingNotifier {
  late final StopWatchTimer _stopWatchTimer;

  String _bookId = '';
  ReadingProgressModel? _initialProgress;
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;

  bool get isInitialized => _isInitialized;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  String get bookId => _bookId;
  ReadingProgressModel? get initialProgress => _initialProgress;

  @override
  StopWatchTimer build() {
    _stopWatchTimer = StopWatchTimer(mode: StopWatchMode.countUp);
    ref.onDispose(() {
      _stopWatchTimer.dispose();
    });
    return _stopWatchTimer;
  }

  Future<bool> initializeSession(String bookId, {Book? initialBook}) async {
    if (_isInitialized) {
      return !_hasError;
    }

    try {
      _bookId = bookId;

      var progress = await ref.read(
        readingTrackerNotifierProvider(bookId).future,
      );

      if (progress == null && initialBook != null) {
        final db = await SqfliteService.instance.database;
        await db.insert(
          'bookmarks',
          initialBook.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        _initialProgress = ReadingProgressModel(
          bookId: bookId,
          currentPage: 0,
          totalReadingTimeInSeconds: 0,
          book: initialBook,
        );
        await SqfliteService.instance.saveReadingProgress(_initialProgress!);
        ref.invalidate(readingTrackerNotifierProvider(bookId));
      } else if (progress == null) {
        _hasError = true;
        _errorMessage = 'Book data not found for session recording.';
        _isInitialized = true;
        return false;
      } else {
        _initialProgress = progress;
      }

      if (_initialProgress?.book == null) {
        _hasError = true;
        _errorMessage = 'Book data not found for session recording.';
        _isInitialized = true;
        return false;
      }

      _isInitialized = true;
      ref.read(activeSessionProvider.notifier).state = bookId;
      _stopWatchTimer.onStartTimer();

      return true;
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to load book data: ${e.toString()}';
      _isInitialized = true;
      return false;
    }
  }

  void startTimer() {
    if (_isInitialized && !_hasError) {
      _stopWatchTimer.onStartTimer();
    }
  }

  void pauseTimer() => _stopWatchTimer.onStopTimer();

  void resetTimer() => _stopWatchTimer.onResetTimer();

  void disposeTimer() => _stopWatchTimer.dispose();

  void resetState() {
    _bookId = '';
    _initialProgress = null;
    _isInitialized = false;
    _hasError = false;
    _errorMessage = null;
    _stopWatchTimer.onResetTimer();
  }

  void disposeSession({bool wasSaved = false}) {
    _stopWatchTimer.onStopTimer();
    _stopWatchTimer.onResetTimer();
    final bookId = _bookId;
    final initialized = _isInitialized;
    if (!wasSaved && bookId.isNotEmpty && initialized) {
      SqfliteService.instance.deleteReadingProgress(bookId).then((_) {
        ref.invalidate(activeReadingProgressProvider);
        ref.invalidate(readingTrackerNotifierProvider(bookId));
        ref.invalidate(bookmarkNotifierProvider);
      });
    }
    ref.read(activeSessionProvider.notifier).state = null;
    _bookId = '';
    _initialProgress = null;
    _isInitialized = false;
    _hasError = false;
    _errorMessage = null;
  }

  Future<void> cancelSession() async {
    if (!_isInitialized) return;
    _stopWatchTimer.onStopTimer();
    if (_bookId.isNotEmpty) {
      await SqfliteService.instance.deleteReadingProgress(_bookId);
      ref.invalidate(activeReadingProgressProvider);
      ref.invalidate(readingTrackerNotifierProvider(_bookId));
      ref.invalidate(bookmarkNotifierProvider);
    }
    ref.read(activeSessionProvider.notifier).state = null;
    resetState();
  }

  Future<bool> saveSession(int endPage) async {
    if (_hasError || !_isInitialized || _initialProgress == null) {
      return false;
    }

    try {
      final totalElapsedSeconds = _stopWatchTimer.rawTime.value ~/ 1000;

      await ref
          .read(readingTrackerNotifierProvider(_bookId).notifier)
          .updateReadingProgress(
            endPage,
            durationInSeconds: totalElapsedSeconds,
          );

      final session = ReadingSessionModel(
        bookId: _bookId,
        durationInSeconds: totalElapsedSeconds,
        endPage: endPage,
        timestamp: DateTime.now(),
      );
      await ref
          .read(readingTrackerNotifierProvider(_bookId).notifier)
          .addReadingSession(session);

      ref.invalidate(bookReadingSessionsProvider(_bookId));
      ref.invalidate(readingTrackerNotifierProvider(_bookId));
      ref.invalidate(activeReadingProgressProvider);
      ref.invalidate(bookmarkNotifierProvider);

      return true;
    } catch (e) {
      _errorMessage = 'Failed to save session: ${e.toString()}';
      return false;
    }
  }
}
