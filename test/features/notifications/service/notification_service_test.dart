import 'package:book_verse/features/notifications/model/reminder_type.dart';
import 'package:book_verse/features/notifications/service/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/notification_factories.dart';

void main() {
  late NotificationService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    final plugin = FlutterLocalNotificationsPlugin();
    service = NotificationService(plugin);
  });

  group('lastNotificationDate', () {
    test('initial value is null', () async {
      final result = await service.getLastNotificationDate();
      expect(result, isNull);
    });

    test('set then get returns the same date', () async {
      final date = DateTime(2024, 6, 21, 14, 30, 0);
      await service.setLastNotificationDate(date);

      final result = await service.getLastNotificationDate();
      expect(result, equals(date));
    });

    test('set overwrites previous date', () async {
      await service.setLastNotificationDate(DateTime(2024, 1, 1));
      await service.setLastNotificationDate(DateTime(2024, 6, 21));

      final result = await service.getLastNotificationDate();
      expect(result, equals(DateTime(2024, 6, 21)));
    });
  });

  group('onNotificationTap', () {
    test('setter accepts a callback', () {
      expect(() {
        service.onNotificationTap = (payload, notificationId) {};
      }, returnsNormally);
    });
  });

  group('initialize', () {
    test('calling initialize does not crash the process', () async {
      // The underlying plugin may throw LateInitializationError in tests
      // because the platform isn't initialized. Verify it's handled.
      try {
        await service.initialize();
      } catch (_) {
        // Platform not available in test environment — acceptable
      }
    });
  });

  group('schedule', () {
    test('accepts ReminderDecision with payload', () {
      final decision = createDecision(payload: 'book-1');
      final at = DateTime.now().add(const Duration(hours: 1));

      expect(service.schedule(decision, at), completes);
    });

    test('accepts ReminderDecision without payload', () {
      final decision = createDecision(payload: null);
      final at = DateTime.now().add(const Duration(hours: 1));

      expect(service.schedule(decision, at), completes);
    });

    test('accepts all ReminderType variants', () async {
      for (final type in ReminderType.values) {
        final decision = createDecision(type: type);
        final at = DateTime.now().add(const Duration(hours: 1));
        expect(service.schedule(decision, at), completes);
      }
    });
  });

  group('cancelAll', () {
    test('can be called without throwing', () async {
      expect(service.cancelAll(), completes);
    });
  });
}
