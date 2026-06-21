import 'package:book_verse/core/utils/clock.dart';
import 'package:book_verse/core/utils/page_utils.dart';
import 'package:book_verse/core/utils/streak_utils.dart';
import 'package:book_verse/features/reading_tracker/data/reading_tracker_datasource.dart';
import 'package:book_verse/features/insights/model/insights_state.dart';
import 'package:book_verse/features/library/model/library_repo_di.dart';
import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';
import 'package:book_verse/features/reading_tracker/model/reading_session_model.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'insights_viewmodel.g.dart';

@Riverpod(keepAlive: true)
class Insights extends _$Insights {
  @override
  Future<InsightsState> build() async {
    final clock = ref.watch(clockProvider);
    final repo = ref.watch(libraryRepoProvider);
    final datasource = ref.watch(readingTrackerDatasourceProvider);
    final sessions = await datasource.getAllReadingSessions();
    final allProgress = await repo.getAllProgressWithBooks();

    final allSessionList = sessions.toList();

    final totalMinutes =
        (allSessionList.fold<int>(0, (sum, s) => sum + s.durationInSeconds) /
                60)
            .ceil();

    final totalPages = computeAllTimePages(allSessionList);
    final totalBooks = allSessionList.map((s) => s.bookId).toSet().length;

    final now = clock.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final currentStreak = computeStreak(allSessionList, todayStart);
    final longestStreak = computeLongestStreak(allSessionList);
    final streakHistory = _buildStreakHistory(allSessionList, todayStart);

    final streakStatus = _computeStreakStatus(
      currentStreak: currentStreak,
      totalBooks: totalBooks,
    );

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
    final ytdPages = computePagesInRange(
      ytdSessions,
      allSessionList,
      yearStart,
    );

    return InsightsState(
      totalMinutes: totalMinutes,
      totalPages: totalPages,
      totalBooks: totalBooks,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      streakHistory: streakHistory,
      streakStatus: streakStatus,
      achievements: achievements,
      genreDistribution: genreDistribution,
      monthlyMinutes: monthlyMinutes,
      ytdMinutes: ytdMinutes,
      ytdPages: ytdPages,
    );
  }
}

StreakStatus _computeStreakStatus({
  required int currentStreak,
  required int totalBooks,
}) {
  if (totalBooks == 0) return StreakStatus.none;
  if (currentStreak == 0) return StreakStatus.broken;
  if (currentStreak < 3) return StreakStatus.atRisk;
  return StreakStatus.active;
}

List<StreakDay> _buildStreakHistory(
  List<ReadingSessionModel> allSessions,
  DateTime todayStart,
) {
  final durationByDay = <DateTime, int>{};
  for (final s in allSessions) {
    final date = DateTime(s.timestamp.year, s.timestamp.month, s.timestamp.day);
    durationByDay[date] = (durationByDay[date] ?? 0) + s.durationInSeconds;
  }

  final days = <StreakDay>[];
  for (var i = 89; i >= 0; i--) {
    final date = todayStart.subtract(Duration(days: i));
    final durationSeconds = durationByDay[date] ?? 0;
    days.add(
      StreakDay(
        date: date,
        hasActivity: durationSeconds > 0,
        durationSeconds: durationSeconds,
      ),
    );
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
  final bestStreak = currentStreak > longestStreak
      ? currentStreak
      : longestStreak;

  return [
    Achievement(
      id: 'bookworm',
      title: 'Bookworm',
      description: 'Read 100+ pages total',
      targetDescription: '${totalPages.clamp(0, 100)}/100 pages',
      icon: Icons.auto_stories,
      unlocked: totalPages >= 100,
      progress: (totalPages / 100).clamp(0.0, 1.0),
    ),
    Achievement(
      id: 'streak_starter',
      title: 'Streak Starter',
      description: '3-day reading streak',
      targetDescription: '${bestStreak.clamp(0, 3)}/3 days',
      icon: Icons.local_fire_department,
      unlocked: currentStreak >= 3 || longestStreak >= 3,
      progress: (bestStreak / 3).clamp(0.0, 1.0),
    ),
    Achievement(
      id: 'dedicated',
      title: 'Dedicated Reader',
      description: '7-day reading streak',
      targetDescription: '${bestStreak.clamp(0, 7)}/7 days',
      icon: Icons.whatshot,
      unlocked: currentStreak >= 7 || longestStreak >= 7,
      progress: (bestStreak / 7).clamp(0.0, 1.0),
    ),
    Achievement(
      id: 'marathon',
      title: 'Marathon',
      description: '10+ hours total reading',
      targetDescription: '${totalHours.clamp(0, 10)}/10 hours',
      icon: Icons.directions_run,
      unlocked: totalHours >= 10,
      progress: (totalHours / 10).clamp(0.0, 1.0),
    ),
    Achievement(
      id: 'explorer',
      title: 'Explorer',
      description: 'Read 5+ different books',
      targetDescription: '${totalBooks.clamp(0, 5)}/5 books',
      icon: Icons.explore,
      unlocked: totalBooks >= 5,
      progress: (totalBooks / 5).clamp(0.0, 1.0),
    ),
    Achievement(
      id: 'bibliophile',
      title: 'Bibliophile',
      description: 'Read 10+ different books',
      targetDescription: '${totalBooks.clamp(0, 10)}/10 books',
      icon: Icons.library_books,
      unlocked: totalBooks >= 10,
      progress: (totalBooks / 10).clamp(0.0, 1.0),
    ),
    Achievement(
      id: 'century',
      title: 'Century',
      description: 'Read 1,000+ pages total',
      targetDescription: '${totalPages.clamp(0, 1000)}/1,000 pages',
      icon: Icons.trending_up,
      unlocked: totalPages >= 1000,
      progress: (totalPages / 1000).clamp(0.0, 1.0),
    ),
    Achievement(
      id: 'night_owl',
      title: 'Night Owl',
      description: 'Read past midnight',
      targetDescription: 'Read after midnight',
      icon: Icons.dark_mode,
      unlocked: allSessions.any(
        (s) => s.timestamp.hour >= 0 && s.timestamp.hour < 5,
      ),
      progress:
          allSessions.any((s) => s.timestamp.hour >= 0 && s.timestamp.hour < 5)
          ? 1.0
          : 0.0,
    ),
  ]..sort((a, b) {
    if (a.unlocked && !b.unlocked) return -1;
    if (!a.unlocked && b.unlocked) return 1;
    return b.progress.compareTo(a.progress);
  });
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
  final monthRangeEnd = DateTime(firstDay.year, firstDay.month + 1, 1);
  final filtered = allSessions
      .where(
        (s) =>
            !s.timestamp.isBefore(firstDay) &&
            s.timestamp.isBefore(monthRangeEnd),
      )
      .toList();
  return computePagesInRange(filtered, allSessions, firstDay);
}
