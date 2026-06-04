import 'package:book_verse/core/services/sqflite_service.dart';
import 'package:book_verse/features/insights/model/insights_state.dart';
import 'package:book_verse/features/library/model/library_repo_di.dart';
import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';
import 'package:book_verse/features/reading_tracker/model/reading_session_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

final insightsProvider = FutureProvider<InsightsState>((ref) async {
  final repo = ref.watch(libraryRepoProvider);
  final sessions = await SqfliteService.instance.getAllReadingSessions();
  final allProgress = await repo.getAllProgressWithBooks();

  final allSessionList = sessions.toList();

  final totalMinutes =
      (allSessionList.fold<int>(0, (sum, s) => sum + s.durationInSeconds) / 60)
          .ceil();

  final totalPages = _computeAllTimePages(allSessionList);
  final totalBooks = allSessionList.map((s) => s.bookId).toSet().length;

  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final currentStreak = _computeStreak(allSessionList, todayStart);
  final longestStreak = _computeLongestStreak(allSessionList);
  final streakHistory = _buildStreakHistory(allSessionList, todayStart);

  final achievements = _computeAchievements(
    totalPages: totalPages,
    currentStreak: currentStreak,
    longestStreak: longestStreak,
    totalMinutes: totalMinutes,
    totalBooks: totalBooks,
    allSessions: allSessionList,
  );

  final genreDistribution = _computeGenreDistribution(allProgress);

  final monthlyMinutes = _computeMonthlyMinutes(allSessionList);

  final yearStart = DateTime(now.year, 1, 1);
  final ytdSessions = allSessionList
      .where(
        (s) =>
            !s.timestamp.isBefore(yearStart) &&
            s.timestamp.isBefore(todayStart.add(const Duration(days: 1))),
      )
      .toList();
  final ytdMinutes =
      (ytdSessions.fold<int>(0, (sum, s) => sum + s.durationInSeconds) / 60)
          .ceil();
  final ytdPages = _computePagesInRange(
    allSessionList,
    yearStart,
    todayStart.add(const Duration(days: 1)),
  );

  return InsightsState(
    totalMinutes: totalMinutes,
    totalPages: totalPages,
    totalBooks: totalBooks,
    currentStreak: currentStreak,
    longestStreak: longestStreak,
    streakHistory: streakHistory,
    achievements: achievements,
    genreDistribution: genreDistribution,
    monthlyMinutes: monthlyMinutes,
    ytdMinutes: ytdMinutes,
    ytdPages: ytdPages,
  );
});

int _computeAllTimePages(List<ReadingSessionModel> allSessions) {
  final byBook = <String, List<ReadingSessionModel>>{};
  for (final s in allSessions) {
    byBook.putIfAbsent(s.bookId, () => []).add(s);
  }

  int total = 0;
  for (final entry in byBook.entries) {
    final bookSessions = entry.value
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    int prevPage = 0;
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

int _computeLongestStreak(List<ReadingSessionModel> allSessions) {
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

List<StreakDay> _buildStreakHistory(
  List<ReadingSessionModel> allSessions,
  DateTime todayStart,
) {
  final activeDays = allSessions
      .map(
        (s) => DateTime(s.timestamp.year, s.timestamp.month, s.timestamp.day),
      )
      .toSet();

  final days = <StreakDay>[];
  for (var i = 89; i >= 0; i--) {
    final date = todayStart.subtract(Duration(days: i));
    days.add(StreakDay(date: date, hasActivity: activeDays.contains(date)));
  }
  return days;
}

List<Achievement> _computeAchievements({
  required int totalPages,
  required int currentStreak,
  required int longestStreak,
  required int totalMinutes,
  required int totalBooks,
  required List<ReadingSessionModel> allSessions,
}) {
  final totalHours = (totalMinutes / 60).floor();

  return [
    Achievement(
      id: 'bookworm',
      title: 'Bookworm',
      description: 'Read 100+ pages total',
      icon: Icons.auto_stories,
      unlocked: totalPages >= 100,
    ),
    Achievement(
      id: 'streak_starter',
      title: 'Streak Starter',
      description: '3-day reading streak',
      icon: Icons.local_fire_department,
      unlocked: currentStreak >= 3 || longestStreak >= 3,
    ),
    Achievement(
      id: 'dedicated',
      title: 'Dedicated Reader',
      description: '7-day reading streak',
      icon: Icons.whatshot,
      unlocked: currentStreak >= 7 || longestStreak >= 7,
    ),
    Achievement(
      id: 'marathon',
      title: 'Marathon',
      description: '10+ hours total reading',
      icon: Icons.directions_run,
      unlocked: totalHours >= 10,
    ),
    Achievement(
      id: 'explorer',
      title: 'Explorer',
      description: 'Read 5+ different books',
      icon: Icons.explore,
      unlocked: totalBooks >= 5,
    ),
    Achievement(
      id: 'bibliophile',
      title: 'Bibliophile',
      description: 'Read 10+ different books',
      icon: Icons.library_books,
      unlocked: totalBooks >= 10,
    ),
    Achievement(
      id: 'century',
      title: 'Century',
      description: 'Read 1,000+ pages total',
      icon: Icons.trending_up,
      unlocked: totalPages >= 1000,
    ),
    Achievement(
      id: 'night_owl',
      title: 'Night Owl',
      description: 'Read past midnight',
      icon: Icons.dark_mode,
      unlocked: allSessions.any(
        (s) => s.timestamp.hour >= 0 && s.timestamp.hour < 5,
      ),
    ),
  ];
}

List<GenreStat> _computeGenreDistribution(
  List<ReadingProgressModel> allProgress,
) {
  final genreCounts = <String, int>{};
  for (final progress in allProgress) {
    final book = progress.book;
    if (book == null) continue;
    final categories = book.categories;
    if (categories == null || categories.isEmpty) {
      genreCounts['Uncategorized'] = (genreCounts['Uncategorized'] ?? 0) + 1;
      continue;
    }
    for (final cat in categories) {
      final genre = cat.toString().trim();
      if (genre.isNotEmpty) {
        genreCounts[genre] = (genreCounts[genre] ?? 0) + 1;
      }
    }
  }

  final total = genreCounts.values.fold(0, (a, b) => a + b);
  if (total == 0) return [];

  return genreCounts.entries
      .map(
        (e) => GenreStat(
          genre: e.key,
          bookCount: e.value,
          percentage: (e.value / total) * 100,
        ),
      )
      .toList()
    ..sort((a, b) => b.bookCount.compareTo(a.bookCount));
}

List<MonthlySummary> _computeMonthlyMinutes(
  List<ReadingSessionModel> allSessions,
) {
  final byMonth = <int, Map<int, List<ReadingSessionModel>>>{};

  for (final s in allSessions) {
    byMonth.putIfAbsent(s.timestamp.year, () => {});
    byMonth[s.timestamp.year]!.putIfAbsent(s.timestamp.month, () => []).add(s);
  }

  final result = <MonthlySummary>[];
  final sortedYears = byMonth.keys.toList()..sort();
  for (final year in sortedYears) {
    final months = byMonth[year]!;
    final sortedMonths = months.keys.toList()..sort();
    for (final month in sortedMonths) {
      final monthSessions = months[month]!;
      final minutes =
          (monthSessions.fold<int>(0, (sum, s) => sum + s.durationInSeconds) /
                  60)
              .ceil();
      final pages = _computePagesInMonth(monthSessions, allSessions);
      result.add(
        MonthlySummary(
          month: month,
          year: year,
          minutes: minutes,
          pages: pages,
        ),
      );
    }
  }
  return result;
}

int _computePagesInMonth(
  List<ReadingSessionModel> monthSessions,
  List<ReadingSessionModel> allSessions,
) {
  if (monthSessions.isEmpty) return 0;
  final firstDay = DateTime(
    monthSessions.first.timestamp.year,
    monthSessions.first.timestamp.month,
    1,
  );
  return _computePagesInRange(
    allSessions,
    firstDay,
    DateTime(firstDay.year, firstDay.month + 1, 1),
  );
}

int _computePagesInRange(
  List<ReadingSessionModel> allSessions,
  DateTime rangeStart,
  DateTime rangeEnd,
) {
  final rangeSessions = allSessions
      .where(
        (s) =>
            !s.timestamp.isBefore(rangeStart) && s.timestamp.isBefore(rangeEnd),
      )
      .toList();

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
