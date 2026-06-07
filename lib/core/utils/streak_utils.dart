import 'package:book_verse/features/reading_tracker/model/reading_session_model.dart';

int computeStreak(List<ReadingSessionModel> allSessions, DateTime todayStart) {
  int streak = 0;
  for (var i = 0; ; i++) {
    final dayStart = todayStart.subtract(Duration(days: i));
    final dayEnd = dayStart.add(const Duration(days: 1));
    final hasActivity = allSessions.any(
      (s) => !s.timestamp.isBefore(dayStart) && s.timestamp.isBefore(dayEnd),
    );
    if (hasActivity) {
      streak++;
    } else {
      break;
    }
  }
  return streak;
}

int computeLongestStreak(List<ReadingSessionModel> allSessions) {
  if (allSessions.isEmpty) return 0;

  final dates =
      allSessions
          .map(
            (s) =>
                DateTime(s.timestamp.year, s.timestamp.month, s.timestamp.day),
          )
          .toSet()
          .toList()
        ..sort();

  int longest = 0;
  int current = 1;
  for (var i = 1; i < dates.length; i++) {
    if (dates[i].difference(dates[i - 1]).inDays == 1) {
      current++;
    } else {
      longest = current > longest ? current : longest;
      current = 1;
    }
  }
  longest = current > longest ? current : longest;
  return longest;
}
