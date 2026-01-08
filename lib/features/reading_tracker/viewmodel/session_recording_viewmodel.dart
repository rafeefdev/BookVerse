import 'dart:async';

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

  @override
  StopWatchTimer build() {
    _stopWatchTimer = StopWatchTimer(mode: StopWatchMode.countUp);
    return _stopWatchTimer;
  }

  void initializeSession(String bookId, ReadingProgressModel? initialProgress) {
    _bookId = bookId;
    _initialProgress = initialProgress;
    _stopWatchTimer.onStartTimer();
  }

  String get bookId => _bookId;
  ReadingProgressModel? get initialProgress => _initialProgress;

  void startTimer() => _stopWatchTimer.onStartTimer();
  void pauseTimer() => _stopWatchTimer.onStopTimer();
  void resetTimer() => _stopWatchTimer.onResetTimer();
  void disposeTimer() => _stopWatchTimer.dispose();

  Future<void> saveSession(int endPage) async {
    final totalElapsedSeconds = _stopWatchTimer.rawTime.value ~/ 1000;

    // Update reading progress
    await ref
        .read(readingTrackerNotifierProvider(_bookId).notifier)
        .updateReadingProgress(endPage, durationInSeconds: totalElapsedSeconds);

    // Add reading session
    final session = ReadingSessionModel(
      bookId: _bookId,
      durationInSeconds: totalElapsedSeconds,
      endPage: endPage,
      timestamp: DateTime.now(),
    );
    await ref
        .read(readingTrackerNotifierProvider(_bookId).notifier)
        .addReadingSession(session);

    // Invalidate book sessions provider to refresh UI
    ref.invalidate(bookReadingSessionsProvider(_bookId));
    ref.invalidate(readingTrackerNotifierProvider(_bookId));
  }
}
