import 'package:book_verse/core/models/book_model.dart';
import 'package:book_verse/core/utils/clock.dart';
import 'package:book_verse/core/utils/page_utils.dart';
import 'package:book_verse/features/bookmarks/data/bookmark_datasource.dart';
import 'package:book_verse/features/dashboard/model/dashboard_state.dart';
import 'package:book_verse/features/dashboard/model/weekly_book_summary.dart';
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
  final bookmarkDatasource = ref.watch(bookmarkDatasourceProvider);
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

  // Books read this week
  final bookMaps = await bookmarkDatasource.getBookmarkedBooks();
  final bookMap = <String, Book>{};
  for (final b in bookMaps) {
    final book = Book.fromJson(b);
    bookMap[book.id] = book;
  }

  final byBook = <String, List<ReadingSessionModel>>{};
  for (final s in weekSessions) {
    byBook.putIfAbsent(s.bookId, () => []).add(s);
  }

  final booksRead = byBook.entries.map((entry) {
    final bookSessions = entry.value;
    final book = bookMap[entry.key];
    final totalDur = bookSessions.fold<int>(
      0,
      (s, s2) => s + s2.durationInSeconds,
    );
    final bookPages = computePagesInRange(bookSessions, sessions, weekStart);
    return WeeklyBookSummary(
      book:
          book ??
          Book(
            id: entry.key,
            title: 'Unknown Book',
            authors: [],
            subTitle: '',
            publisher: '',
            publishedDate: '',
            description: '',
            thumbnail: '',
            pageCount: 0,
          ),
      totalSessions: bookSessions.length,
      totalDurationSeconds: totalDur,
      totalPages: bookPages,
    );
  }).toList();

  booksRead.sort(
    (a, b) => b.totalDurationSeconds.compareTo(a.totalDurationSeconds),
  );

  return WeeklyReportState(
    weeklyReading: weeklyReading,
    totalPages: totalPages,
    totalMinutes: totalMinutes,
    totalSessions: totalSessions,
    activeDays: activeDays,
    weekStart: weekStart,
    weekEnd: weekEnd,
    booksRead: booksRead,
  );
});

DateTime _weekStart(DateTime date) {
  final d = date.subtract(Duration(days: date.weekday - 1));
  return DateTime(d.year, d.month, d.day);
}
