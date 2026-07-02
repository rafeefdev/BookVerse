import 'package:book_verse/core/utils/clock.dart';
import 'package:book_verse/features/goals/data/goals_datasource.dart';
import 'package:book_verse/features/notifications/providers/notification_providers.dart';
import 'package:book_verse/features/notifications/service/notification_service.dart';
import 'package:book_verse/features/notifications/service/reminder_engine.dart';
import 'package:book_verse/features/reading_tracker/data/reading_tracker_datasource.dart';
import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';
import 'package:book_verse/features/reading_tracker/model/reading_session_model.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../helpers/test_db.dart';

void main() {
  late Database db;
  late ReadingTrackerDatasource datasource;
  late GoalsDatasource goalsDatasource;
  late NotificationService notificationService;
  late SharedPreferences prefs;
  late ReminderEngine engine;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = await openTestDb();
    datasource = ReadingTrackerDatasource(db);
    goalsDatasource = GoalsDatasource(db);
    notificationService = NotificationService(
      FlutterLocalNotificationsPlugin(),
    );
    prefs = await SharedPreferences.getInstance();
    engine = const ReminderEngine();
  });

  tearDown(() async {
    await db.close();
  });

  group('scheduleDailyReminderWithServices (integration)', () {
    test('no sessions, no progress → does not schedule', () async {
      final now = DateTime(2024, 6, 21, 12, 0, 0);

      await scheduleDailyReminderWithServices(
        notificationService: notificationService,
        engine: engine,
        clock: FakeClock(now),
        datasource: datasource,
        prefs: prefs,
        goalsDatasource: goalsDatasource,
      );

      final lastDate = await notificationService.getLastNotificationDate();
      expect(lastDate, isNull);
    });

    test('one session yesterday, streak 0 → schedules reengagement', () async {
      final now = DateTime(2024, 6, 21, 12, 0, 0);
      final yesterday = now.subtract(const Duration(days: 1));

      await datasource.saveReadingSession(
        ReadingSessionModel(
          bookId: 'b1',
          durationInSeconds: 300,
          endPage: 15,
          timestamp: yesterday,
        ),
      );

      await scheduleDailyReminderWithServices(
        notificationService: notificationService,
        engine: engine,
        clock: FakeClock(now),
        datasource: datasource,
        prefs: prefs,
        goalsDatasource: goalsDatasource,
      );

      final lastDate = await notificationService.getLastNotificationDate();
      expect(lastDate, isNotNull);

      // For streak=0, bestTime defaults to preferredHour=19 (from ReminderSettings)
      // Since now is 12:00, 19:00 is in the future so it schedules for 19:00
      expect(lastDate!.hour, 19);
    });

    test('has session today → does not schedule', () async {
      final now = DateTime(2024, 6, 21, 12, 0, 0);

      await datasource.saveReadingSession(
        ReadingSessionModel(
          bookId: 'b1',
          durationInSeconds: 300,
          endPage: 15,
          timestamp: now.subtract(const Duration(hours: 1)),
        ),
      );

      await scheduleDailyReminderWithServices(
        notificationService: notificationService,
        engine: engine,
        clock: FakeClock(now),
        datasource: datasource,
        prefs: prefs,
        goalsDatasource: goalsDatasource,
      );

      final lastDate = await notificationService.getLastNotificationDate();
      expect(
        lastDate,
        isNull,
        reason: 'should not schedule when already read today',
      );
    });

    test('already notified today → does not schedule again', () async {
      final now = DateTime(2024, 6, 21, 12, 0, 0);
      final yesterday = now.subtract(const Duration(days: 1));

      // Seed a last notification date from yesterday
      await prefs.setString(
        'last_notification_date',
        yesterday.toIso8601String(),
      );

      await datasource.saveReadingSession(
        ReadingSessionModel(
          bookId: 'b1',
          durationInSeconds: 300,
          endPage: 15,
          timestamp: yesterday,
        ),
      );

      await scheduleDailyReminderWithServices(
        notificationService: notificationService,
        engine: engine,
        clock: FakeClock(now),
        datasource: datasource,
        prefs: prefs,
        goalsDatasource: goalsDatasource,
      );

      final firstDate = await notificationService.getLastNotificationDate();
      expect(firstDate, isNotNull);

      // Second call same day — should NOT update (shouldScheduleToday returns false)
      await scheduleDailyReminderWithServices(
        notificationService: notificationService,
        engine: engine,
        clock: FakeClock(now),
        datasource: datasource,
        prefs: prefs,
        goalsDatasource: goalsDatasource,
      );

      final secondDate = await notificationService.getLastNotificationDate();
      expect(
        secondDate,
        equals(firstDate),
        reason:
            'should not overwrite last notification date with a different value',
      );
    });

    test(
      'sessions yesterday through 3 days ago → reengagement (no session today)',
      () async {
        final now = DateTime(2024, 6, 21, 12, 0, 0);

        await datasource.saveReadingSession(
          ReadingSessionModel(
            bookId: 'b1',
            durationInSeconds: 300,
            endPage: 15,
            timestamp: now.subtract(const Duration(days: 1)),
          ),
        );
        await datasource.saveReadingSession(
          ReadingSessionModel(
            bookId: 'b1',
            durationInSeconds: 300,
            endPage: 10,
            timestamp: now.subtract(const Duration(days: 2)),
          ),
        );
        await datasource.saveReadingSession(
          ReadingSessionModel(
            bookId: 'b1',
            durationInSeconds: 300,
            endPage: 5,
            timestamp: now.subtract(const Duration(days: 3)),
          ),
        );

        await scheduleDailyReminderWithServices(
          notificationService: notificationService,
          engine: engine,
          clock: FakeClock(now),
          datasource: datasource,
          prefs: prefs,
          goalsDatasource: goalsDatasource,
        );

        final lastDate = await notificationService.getLastNotificationDate();
        expect(lastDate, isNotNull);
        // No session today → streak=0 in the computation → bestTime=19
        expect(lastDate!.hour, 19);
      },
    );
  });

  group('book filtering', () {
    test('progress with null book excluded from currentlyReading', () async {
      final now = DateTime(2024, 6, 22, 12, 0, 0);

      await datasource.saveReadingProgress(
        ReadingProgressModel(bookId: 'b1', currentPage: 50),
      );

      await scheduleDailyReminderWithServices(
        notificationService: notificationService,
        engine: engine,
        clock: FakeClock(now),
        datasource: datasource,
        prefs: prefs,
        goalsDatasource: goalsDatasource,
      );

      final lastDate = await notificationService.getLastNotificationDate();
      expect(
        lastDate,
        isNull,
        reason: 'progress without book should be excluded',
      );
    });
  });
}
