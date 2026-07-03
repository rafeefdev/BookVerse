import 'package:book_verse/features/reading_tracker/model/reading_session_model.dart';

class AdaptiveTimeLearner {
  static const int minSessions = 10;
  static const int recomputeIntervalDays = 7;
  static const int minHour = 6;
  static const int maxHour = 23;

  /// Returns optimal notification hour [0-23] based on histogram of session
  /// start times. Returns null when insufficient data (< [minSessions]).
  static int? computeOptimalHour(List<ReadingSessionModel> sessions) {
    if (sessions.length < minSessions) return null;

    final histogram = <int, int>{};
    for (final s in sessions) {
      final hour = s.timestamp.hour;
      histogram[hour] = (histogram[hour] ?? 0) + 1;
    }

    final bestHour = histogram.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    if (bestHour < minHour || bestHour > maxHour) return null;
    return bestHour;
  }
}
