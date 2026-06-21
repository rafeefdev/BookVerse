import 'package:book_verse/features/notifications/model/reminder_type.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin;

  NotificationService(this._plugin);

  static const _lastNotificationDateKey = 'last_notification_date';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  void _onNotificationTap(NotificationResponse response) {
    _onTapCallback?.call(response.payload);
  }

  Function(String?)? _onTapCallback;

  set onNotificationTap(Function(String?)? callback) {
    _onTapCallback = callback;
  }

  Future<DateTime?> getLastNotificationDate() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_lastNotificationDateKey);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> setLastNotificationDate(DateTime date) async {
    final prefs = await _prefs;
    await prefs.setString(_lastNotificationDateKey, date.toIso8601String());
  }

  Future<void> schedule(
    ReminderDecision decision,
    DateTime at,
  ) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'reading_reminder',
        'Reading Reminder',
        channelDescription: 'Daily reading reminders and streak alerts',
        importance: Importance.high,
        priority: Priority.high,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final id = at.day;
      final tzAt = tz.TZDateTime.from(at, tz.local);

      await _plugin.zonedSchedule(
        id: id,
        title: decision.title,
        body: decision.body,
        scheduledDate: tzAt,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: decision.payload,
      );
    } catch (_) {
      // Silently handle platform unavailability (e.g. in tests)
    }
  }

  Future<void> cancel({required int id}) async {
    try {
      await _plugin.cancel(id: id);
    } catch (_) {}
  }

  Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }
}
