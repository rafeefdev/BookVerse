import 'package:book_verse/core/utils/clock.dart';
import 'package:book_verse/features/goals/data/goals_datasource.dart';
import 'package:book_verse/features/notifications/model/reminder_type.dart';
import 'package:book_verse/features/notifications/service/notification_service.dart';
import 'package:book_verse/features/notifications/service/reminder_engine.dart';
import 'package:book_verse/features/reading_tracker/data/reading_tracker_datasource.dart';
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

  final currentlyReading =
      allProgress
          .where((p) => p.book != null && p.currentPage < p.effectivePageCount)
          .toList()
        ..sort(
          (a, b) => (b.lastRead ?? DateTime(2000)).compareTo(
            a.lastRead ?? DateTime(2000),
          ),
        );

  final allSessionList = sessions.toList();

  // compute streak
  int streak = 0;
  for (var i = 0; ; i++) {
    final dayStart = todayStart.subtract(Duration(days: i));
    final dayEnd = dayStart.add(const Duration(days: 1));
    final hasActivity = allSessionList.any(
      (s) => !s.timestamp.isBefore(dayStart) && s.timestamp.isBefore(dayEnd),
    );
    if (hasActivity) {
      streak++;
    } else {
      break;
    }
  }

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

  final at = engine.bestTime(
    now: now,
    streak: streak,
    lastNotificationDate: lastNotificationDate,
    preferredHour: settings.hour,
    quietStartHour: settings.quietStartHour,
    quietEndHour: settings.quietEndHour,
  );

  await notificationService.cancelAll();
  await notificationService.schedule(decision, at);
  await prefs.setString(_lastNotificationDateKey, at.toIso8601String());
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
