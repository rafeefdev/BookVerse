import 'package:book_verse/core/utils/clock.dart';
import 'package:book_verse/features/notifications/service/notification_service.dart';
import 'package:book_verse/features/notifications/service/reminder_engine.dart';
import 'package:book_verse/features/reading_tracker/data/reading_tracker_datasource.dart';
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
const _disabledUntilKey = 'notifications_disabled_until';

/// Core scheduling logic — testable directly without WidgetRef.
Future<void> scheduleDailyReminderWithServices({
  required NotificationService notificationService,
  required ReminderEngine engine,
  required Clock clock,
  required ReadingTrackerDatasource datasource,
  required SharedPreferences prefs,
}) async {
  // Check if notifications are globally disabled
  final disabledUntilRaw = prefs.getString(_disabledUntilKey);
  if (disabledUntilRaw != null) {
    final disabledUntil = DateTime.tryParse(disabledUntilRaw);
    if (disabledUntil != null && clock.now().isBefore(disabledUntil)) {
      return;
    }
  }

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

  final decision = engine.decide(
    allSessions: allSessionList,
    currentlyReading: currentlyReading,
    now: now,
    streak: streak,
    lastNotificationDate: lastNotificationDate,
  );

  if (decision == null) return;

  final at = engine.bestTime(
    now: now,
    streak: streak,
    lastNotificationDate: lastNotificationDate,
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
  final prefs = await SharedPreferences.getInstance();

  await scheduleDailyReminderWithServices(
    notificationService: service,
    engine: engine,
    clock: clock,
    datasource: datasource,
    prefs: prefs,
  );
}
