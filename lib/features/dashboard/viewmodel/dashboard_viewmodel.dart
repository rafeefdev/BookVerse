import 'package:book_verse/core/utils/page_utils.dart';
import 'package:book_verse/core/utils/streak_utils.dart';
import 'package:book_verse/features/dashboard/model/dashboard_state.dart';
import 'package:book_verse/features/library/viewmodel/library_viewmodel.dart';
import 'package:book_verse/features/reading_tracker/data/reading_tracker_datasource.dart';
import 'package:book_verse/features/reading_tracker/model/reading_session_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_viewmodel.g.dart';

@Riverpod(keepAlive: true)
class Dashboard extends _$Dashboard {
  @override
  Future<DashboardState> build() async {
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
  final todayPages = computePagesInRange(todaySessions, allSessionList, todayStart);

  // yesterday
  final yesterdaySeconds = allSessionList
      .where(
        (s) =>
            !s.timestamp.isBefore(yesterdayStart) &&
            s.timestamp.isBefore(todayStart),
      )
      .fold<int>(0, (sum, s) => sum + s.durationInSeconds);

  // streak
  final streak = computeStreak(allSessionList, todayStart);

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
    final dayPages = computePagesInRange(daySessions, allSessionList, dayDate);
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
  }
}

DateTime _weekStart(DateTime date) {
  final d = date.subtract(Duration(days: date.weekday - 1));
  return DateTime(d.year, d.month, d.day);
}
