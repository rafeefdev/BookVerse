import 'package:book_verse/core/utils/clock.dart';
import 'package:book_verse/core/utils/page_utils.dart';
import 'package:book_verse/features/dashboard/model/dashboard_state.dart';
import 'package:book_verse/features/dashboard/model/weekly_report_state.dart';
import 'package:book_verse/features/reading_tracker/data/reading_tracker_datasource.dart';
import 'package:book_verse/features/reading_tracker/model/reading_session_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final weeklyReportProvider = FutureProvider.family<WeeklyReportState, int>((
  ref,
  weekOffset,
) async {
  final clock = ref.watch(clockProvider);
  final datasource = ref.watch(readingTrackerDatasourceProvider);
  final sessions = await datasource.getAllReadingSessions();

  final now = clock.now();
  final currentWeekStart = _weekStart(now);
  final weekStart = currentWeekStart.add(Duration(days: weekOffset * 7));
  final weekEnd = weekStart.add(const Duration(days: 7));

  final weekSessions = sessions
      .where(
        (s) =>
            !s.timestamp.isBefore(weekStart) && s.timestamp.isBefore(weekEnd),
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
    final dayPages = computePagesInRange(daySessions, sessions, dayDate);
    return DailyReadingMinutes(
      label: labels[i],
      minutes: (daySeconds / 60).ceil(),
      pages: dayPages,
      isToday: weekOffset == 0 && i == now.weekday - 1,
    );
  });

  final totalPages = weeklyReading.fold<int>(0, (sum, d) => sum + d.pages);
  final totalMinutes = weeklyReading.fold<int>(0, (sum, d) => sum + d.minutes);
  final totalSessions = weekSessions.length;
  final activeDays = weeklyReading.where((d) => d.minutes > 0).length;

  return WeeklyReportState(
    weeklyReading: weeklyReading,
    totalPages: totalPages,
    totalMinutes: totalMinutes,
    totalSessions: totalSessions,
    activeDays: activeDays,
    weekStart: weekStart,
    weekEnd: weekEnd,
  );
});

DateTime _weekStart(DateTime date) {
  final d = date.subtract(Duration(days: date.weekday - 1));
  return DateTime(d.year, d.month, d.day);
}
