import 'package:book_verse/features/dashboard/model/dashboard_state.dart';
import 'package:book_verse/features/library/viewmodel/library_viewmodel.dart';
import 'package:book_verse/features/reading_tracker/data/reading_tracker_datasource.dart';
import 'package:book_verse/features/reading_tracker/model/reading_session_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dashboardProvider = FutureProvider<DashboardState>((ref) async {
  final libraryAsync = ref.watch(libraryNotifierProvider);
  final datasource = ref.watch(readingTrackerDatasourceProvider);
  final sessions = await datasource.getAllReadingSessions();

  final libraryState = libraryAsync.valueOrNull;
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final yesterdayStart = todayStart.subtract(const Duration(days: 1));

  final allSessionList = sessions.toList();

  // today
  final todaySessions = allSessionList
      .where((s) => !s.timestamp.isBefore(todayStart))
      .toList();
  final todaySeconds = todaySessions.fold<int>(
    0,
    (sum, s) => sum + s.durationInSeconds,
  );
  final todayPages = _pagesInRange(todaySessions, allSessionList, todayStart);

  // yesterday
  final yesterdaySeconds = allSessionList
      .where(
        (s) =>
            !s.timestamp.isBefore(yesterdayStart) &&
            s.timestamp.isBefore(todayStart),
      )
      .fold<int>(0, (sum, s) => sum + s.durationInSeconds);

  // streak
  final streak = _computeStreak(allSessionList, todayStart);

  // weekly
  final weekStart = _weekStart(now);
  final weekSessions = allSessionList
      .where(
        (s) =>
            !s.timestamp.isBefore(weekStart) &&
            s.timestamp.isBefore(weekStart.add(const Duration(days: 7))),
      )
      .toList();

  final byDay = <int, List<ReadingSessionModel>>{};
  for (final s in weekSessions) {
    byDay.putIfAbsent(s.timestamp.weekday, () => []).add(s);
  }

  const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final weeklyReading = List.generate(7, (i) {
    final day = i + 1;
    final daySessions = byDay[day] ?? [];
    final daySeconds = daySessions.fold<int>(
      0,
      (sum, s) => sum + s.durationInSeconds,
    );
    final dayDate = weekStart.add(Duration(days: i));
    final dayPages = _pagesInRange(daySessions, allSessionList, dayDate);
    return DailyReadingMinutes(
      label: labels[i],
      minutes: (daySeconds / 60).ceil(),
      pages: dayPages,
      isToday: i == now.weekday - 1,
    );
  });

  return DashboardState(
    todayMinutes: (todaySeconds / 60).ceil(),
    todayPages: todayPages,
    yesterdayMinutes: (yesterdaySeconds / 60).ceil(),
    streak: streak,
    weeklyReading: weeklyReading,
    currentlyReading: (libraryState?.currentlyReading ?? []).take(5).toList(),
  );
});

int _pagesInRange(
  List<ReadingSessionModel> rangeSessions,
  List<ReadingSessionModel> allSessions,
  DateTime rangeStart,
) {
  final byBook = <String, List<ReadingSessionModel>>{};
  for (final s in rangeSessions) {
    byBook.putIfAbsent(s.bookId, () => []).add(s);
  }

  int total = 0;
  for (final entry in byBook.entries) {
    final bookSessions = entry.value
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final before =
        allSessions
            .where(
              (s) => s.bookId == entry.key && s.timestamp.isBefore(rangeStart),
            )
            .toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final prevEndPage = before.isNotEmpty ? before.last.endPage : 0;

    int prevPage = prevEndPage;
    int bookTotal = 0;
    for (final session in bookSessions) {
      final start = session.startPage ?? prevPage;
      bookTotal += (session.endPage - start).clamp(0, session.endPage);
      prevPage = session.endPage;
    }
    total += bookTotal;
  }
  return total;
}

int _computeStreak(List<ReadingSessionModel> allSessions, DateTime todayStart) {
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

DateTime _weekStart(DateTime date) {
  final d = date.subtract(Duration(days: date.weekday - 1));
  return DateTime(d.year, d.month, d.day);
}
