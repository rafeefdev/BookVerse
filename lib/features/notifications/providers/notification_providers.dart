import 'package:book_verse/core/utils/clock.dart';
import 'package:book_verse/core/utils/streak_utils.dart';
import 'package:book_verse/features/goals/data/goals_datasource.dart';
import 'package:book_verse/features/notifications/model/reminder_type.dart';
import 'package:book_verse/features/notifications/service/adaptive_time_learner.dart';
import 'package:book_verse/features/notifications/service/notification_service.dart';
import 'package:book_verse/features/notifications/service/reminder_engine.dart';
import 'package:book_verse/features/reading_tracker/data/reading_tracker_datasource.dart';
import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';
import 'package:book_verse/features/reading_tracker/model/reading_session_model.dart';
import 'package:book_verse/features/settings/model/reminder_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

final notificationPluginProvider = Provider<FlutterLocalNotificationsPlugin>(
  (_) => FlutterLocalNotificationsPlugin(),
);

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(ref.watch(notificationPluginProvider)),
);

final reminderEngineProvider = Provider<ReminderEngine>(
  (_) => const ReminderEngine(),
);

const _lastNotificationDateKey = 'last_notification_date';

Future<void> scheduleDailyReminderWithServices({
  required NotificationService notificationService,
  required ReminderEngine engine,
  required Clock clock,
  required ReadingTrackerDatasource datasource,
  required SharedPreferences prefs,
  required GoalsDatasource goalsDatasource,
}) async {
  final settings = await ReminderSettings.load();

  // Check if reminders are globally disabled
  if (!settings.enabled) return;

  final now = clock.now();
  final todayStart = DateTime(now.year, now.month, now.day);

  final sessions = await datasource.getAllReadingSessions();
  final allProgress = await datasource.getAllReadingProgress();
  final allSessionList = sessions.toList();

  final currentlyReading =
      allProgress
          .where((p) => p.book != null && p.currentPage < p.effectivePageCount)
          .toList()
        ..sort(
          (a, b) => _scoreBook(
            b,
            allSessionList,
            now,
          ).compareTo(_scoreBook(a, allSessionList, now)),
        );

  // compute streak using shared utility (consistent with Insights)
  final streak = computeStreak(allSessionList, todayStart);

  final lastNotifRaw = prefs.getString(_lastNotificationDateKey);
  final lastNotificationDate = lastNotifRaw != null
      ? DateTime.tryParse(lastNotifRaw)
      : null;

  // deep inactivity: max 1 per week
  if (allSessionList.isNotEmpty && streak == 0) {
    final sorted = [...allSessionList]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final daysSinceLastRead = now.difference(sorted.first.timestamp).inDays;
    if (daysSinceLastRead > 7 && lastNotificationDate != null) {
      final daysSinceLastNotif = now.difference(lastNotificationDate).inDays;
      if (daysSinceLastNotif < 7) return;
    }
  }

  if (!engine.shouldScheduleToday(
    now: now,
    lastNotificationDate: lastNotificationDate,
  )) {
    return;
  }

  // Compute goal data
  final goal = await goalsDatasource.getGoal();
  bool hasGoal = false;
  bool isGoalBehind = false;
  int pagesBehind = 0;
  if (goal != null && goal.enabled && settings.typeGoal) {
    hasGoal = true;
    final todaySessions = allSessionList.where(
      (s) => !s.timestamp.isBefore(todayStart),
    );
    int pagesRead = 0;
    for (final s in todaySessions) {
      if (s.startPage != null && s.endPage > s.startPage!) {
        pagesRead += s.endPage - s.startPage!;
      }
    }
    pagesBehind = (goal.targetPages - pagesRead).clamp(0, goal.targetPages);
    isGoalBehind = pagesBehind > 0;
  }

  final decision = engine.decide(
    allSessions: allSessionList,
    currentlyReading: currentlyReading,
    now: now,
    streak: streak,
    lastNotificationDate: lastNotificationDate,
    hasGoal: hasGoal && settings.typeGoal,
    isGoalBehind: isGoalBehind,
    pagesBehind: pagesBehind,
  );

  if (decision == null) return;

  // Filter by enabled type
  final typeEnabled = switch (decision.type) {
    ReminderType.resumeBook => settings.typeResumeBook,
    ReminderType.streakProtection => settings.typeStreakProtection,
    ReminderType.reengagement => settings.typeReengagement,
    ReminderType.goalReminder => settings.typeGoal,
  };
  if (!typeEnabled) return;

  // Compute adaptive hour if enabled
  int? adaptiveHour;
  if (settings.adaptiveTiming) {
    adaptiveHour = AdaptiveTimeLearner.computeOptimalHour(allSessionList);
  }

  final at = engine.bestTime(
    now: now,
    streak: streak,
    lastNotificationDate: lastNotificationDate,
    adaptiveHour: adaptiveHour,
    preferredHour: settings.hour,
    quietStartHour: settings.quietStartHour,
    quietEndHour: settings.quietEndHour,
  );

  await notificationService.cancelAll();
  await notificationService.schedule(decision, at);
  await prefs.setString(_lastNotificationDateKey, at.toIso8601String());
}

/// Hybrid score for multi-book priority ordering.
/// Combines recency (40%), engagement (35%), and incompleteness (25%).
double _scoreBook(
  ReadingProgressModel progress,
  List<ReadingSessionModel> allSessions,
  DateTime now,
) {
  double score = 0;

  // Recency: 40% — how recently was this book touched
  final recencyHours = progress.lastRead != null
      ? now.difference(progress.lastRead!).inHours
      : 8760;
  final recencyNorm = (1 - (recencyHours / 8760).clamp(0, 1));
  score += recencyNorm * 0.40;

  // Engagement (7-day): 35% — session count (17.5%) + total duration (17.5%)
  final weekAgo = now.subtract(const Duration(days: 7));
  final recentSessions = allSessions.where(
    (s) => s.bookId == progress.bookId && !s.timestamp.isBefore(weekAgo),
  );
  final sessionCount = recentSessions.length;
  final totalMinutes =
      recentSessions.fold<int>(0, (sum, s) => sum + s.durationInSeconds) / 60;
  score += (sessionCount / 10).clamp(0, 1) * 0.175;
  score += (totalMinutes / 120).clamp(0, 1) * 0.175;

  // Incompleteness: 25% — further from completion = higher priority
  final pct = progress.currentPage / progress.effectivePageCount;
  score += (1 - pct.clamp(0, 1)) * 0.25;

  return score;
}

/// Riverpod integration wrapper.
Future<void> scheduleDailyReminder(WidgetRef ref) async {
  final service = ref.read(notificationServiceProvider);
  final engine = ref.read(reminderEngineProvider);
  final clock = ref.read(clockProvider);
  final datasource = ref.read(readingTrackerDatasourceProvider);
  final goalsDatasource = ref.read(goalsDatasourceProvider);
  final prefs = await SharedPreferences.getInstance();

  await scheduleDailyReminderWithServices(
    notificationService: service,
    engine: engine,
    clock: clock,
    datasource: datasource,
    prefs: prefs,
    goalsDatasource: goalsDatasource,
  );
}
