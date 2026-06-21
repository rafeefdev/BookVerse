import 'dart:async';

import 'package:book_verse/features/bookmarks/viewmodel/bookmark_viewmodel.dart';
import 'package:book_verse/features/library/viewmodel/library_viewmodel.dart';
import 'package:book_verse/features/notifications/providers/notification_providers.dart';
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
  int _startPage = 0;
  bool _needsCatchUp = false;
  bool _disposed = false;
  Timer? _notifTimer;

  bool get isInitialized => _isInitialized;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  String get bookId => _bookId;
  ReadingProgressModel? get initialProgress => _initialProgress;
  int get startPage => _startPage;
  bool get needsCatchUp => _needsCatchUp;

  @override
  StopWatchTimer build() {
    _stopWatchTimer = StopWatchTimer(mode: StopWatchMode.countUp);
    ref.onDispose(() {
      _disposed = true;
      _cancelNotifTimer();
      _cancelNotif();
      _stopWatchTimer.dispose();
    });
    return _stopWatchTimer;
  }

  Future<bool> initializeSession(String bookId) async {
    if (_isInitialized) {
      return !_hasError;
    }

    try {
      _bookId = bookId;

      final progress = await ref.read(
        readingTrackerNotifierProvider(bookId).future,
      );

      _initialProgress = progress;

      if (progress?.book == null) {
        _hasError = true;
        _errorMessage = 'Book data not found for session recording.';
        _isInitialized = true;
        return false;
      }

      if (progress!.currentPage == 0) {
        _needsCatchUp = true;
      } else {
        _startPage = progress.currentPage;
        _stopWatchTimer.onStartTimer();
        _showSessionNotif();
        _startNotifUpdates();
      }

      _registerSessionActionHandler();

      _isInitialized = true;

      return true;
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to load book data: ${e.toString()}';
      _isInitialized = true;
      return false;
    }
  }

  void _registerSessionActionHandler() {
    final service = ref.read(notificationServiceProvider);
    service.onSessionAction = (actionId, payload) {
      if (_disposed) return;
      if (actionId == 'session_pause_resume') {
        if (_stopWatchTimer.isRunning) {
          pauseTimer();
        } else {
          startTimer();
        }
      } else if (actionId == 'session_finish') {
        pauseTimer();
      }
    };
  }

  void _unregisterSessionActionHandler() {
    final service = ref.read(notificationServiceProvider);
    service.onSessionAction = null;
  }

  Future<void> setStartPage(int page) async {
    _startPage = page;
    _needsCatchUp = false;
    await ref
        .read(readingTrackerNotifierProvider(_bookId).notifier)
        .updateReadingProgress(page);
    ref.invalidate(bookmarkNotifierProvider);
    ref.invalidate(libraryNotifierProvider);
    _stopWatchTimer.onStartTimer();
    _showSessionNotif();
    _startNotifUpdates();
  }

  void skipCatchUp() {
    _startPage = 0;
    _needsCatchUp = false;
    _stopWatchTimer.onStartTimer();
    _showSessionNotif();
    _startNotifUpdates();
  }

  void startTimer() {
    if (_isInitialized && !_hasError) {
      _stopWatchTimer.onStartTimer();
      _updateSessionNotif(isPaused: false);
      _startNotifUpdates();
    }
  }

  void pauseTimer() {
    _stopWatchTimer.onStopTimer();
    _cancelNotifTimer();
    _updateSessionNotif(isPaused: true);
  }

  void resetTimer() => _stopWatchTimer.onResetTimer();

  void disposeTimer() {
    _cancelNotif();
    _cancelNotifTimer();
    _unregisterSessionActionHandler();
    _stopWatchTimer.dispose();
  }

  void resetState() {
    _bookId = '';
    _initialProgress = null;
    _isInitialized = false;
    _hasError = false;
    _errorMessage = null;
    _startPage = 0;
    _needsCatchUp = false;
    _cancelNotifTimer();
    _cancelNotif();
    _unregisterSessionActionHandler();
    _stopWatchTimer.onResetTimer();
  }

  Future<bool> saveSession(int endPage, {int? userPageCount}) async {
    if (_hasError || !_isInitialized || _initialProgress == null) {
      return false;
    }

    _stopWatchTimer.onStopTimer();
    _cancelNotifTimer();
    _cancelNotif();
    _unregisterSessionActionHandler();

    try {
      final totalElapsedSeconds = _stopWatchTimer.rawTime.value ~/ 1000;

      await ref
          .read(readingTrackerNotifierProvider(_bookId).notifier)
          .updateReadingProgress(
            endPage,
            durationInSeconds: totalElapsedSeconds,
            userPageCount: userPageCount,
          );

      final session = ReadingSessionModel(
        bookId: _bookId,
        durationInSeconds: totalElapsedSeconds,
        endPage: endPage,
        timestamp: DateTime.now(),
        startPage: _startPage,
      );
      await ref
          .read(readingTrackerNotifierProvider(_bookId).notifier)
          .addReadingSession(session);

      ref.invalidate(bookReadingSessionsProvider(_bookId));
      ref.invalidate(readingTrackerNotifierProvider(_bookId));

      return true;
    } catch (e) {
      _errorMessage = 'Failed to save session: ${e.toString()}';
      return false;
    }
  }

  // --- Ongoing notification helpers ---

  void _showSessionNotif() {
    if (_disposed || _initialProgress?.book == null) return;
    final book = _initialProgress!.book!;
    final page = _initialProgress!.currentPage;
    final total = _initialProgress!.effectivePageCount;

    final service = ref.read(notificationServiceProvider);
    service.showSessionOngoing(
      bookTitle: book.title,
      currentPage: page,
      totalPages: total,
      elapsedSeconds: 0,
      payload: _bookId,
    );
  }

  void _updateSessionNotif({bool isPaused = false}) {
    if (_disposed || _initialProgress?.book == null) return;
    final book = _initialProgress!.book!;
    final page = _initialProgress!.currentPage;
    final total = _initialProgress!.effectivePageCount;
    final elapsed = _stopWatchTimer.rawTime.value ~/ 1000;

    final service = ref.read(notificationServiceProvider);
    service.showSessionOngoing(
      bookTitle: book.title,
      currentPage: page,
      totalPages: total,
      elapsedSeconds: elapsed,
      payload: _bookId,
      isPaused: isPaused,
    );
  }

  void _startNotifUpdates() {
    _cancelNotifTimer();
    _notifTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_disposed) return;
      _updateSessionNotif();
    });
  }

  void _cancelNotifTimer() {
    _notifTimer?.cancel();
    _notifTimer = null;
  }

  void _cancelNotif() {
    final service = ref.read(notificationServiceProvider);
    service.cancelSessionOngoing();
  }
}
