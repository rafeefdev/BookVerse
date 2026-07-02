import 'package:book_verse/features/notifications/model/reminder_type.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin;

  NotificationService(this._plugin);

  static const _lastNotificationDateKey = 'last_notification_date';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<void> initialize({bool requestPermissions = true}) async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open',
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      linux: linuxSettings,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    if (requestPermissions) {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      await androidPlugin?.requestNotificationsPermission();
      await androidPlugin?.requestExactAlarmsPermission();
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    final action = response.actionId;
    if (action == null) {
      _onTapCallback?.call(response.payload, response.id);
      return;
    }
    if (action == 'session_pause_resume' || action == 'session_finish') {
      _onSessionActionCallback?.call(action, response.payload);
    } else {
      _onTapCallback?.call(response.payload, response.id);
    }
  }

  Function(String? payload, int? notificationId)? _onTapCallback;
  Function(String actionId, String? payload)? _onSessionActionCallback;

  set onNotificationTap(
    Function(String? payload, int? notificationId)? callback,
  ) {
    _onTapCallback = callback;
  }

  set onSessionAction(Function(String actionId, String? payload)? callback) {
    _onSessionActionCallback = callback;
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

  Future<void> show({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'reading_reminder',
      'Reading Reminder',
      channelDescription: 'Daily reading reminders and streak alerts',
      importance: Importance.high,
      priority: Priority.high,
    );

    const linuxDetails = LinuxNotificationDetails(
      urgency: LinuxNotificationUrgency.critical,
    );

    const details = NotificationDetails(
      android: androidDetails,
      linux: linuxDetails,
    );

    final id = DateTime.now().millisecondsSinceEpoch.remainder(100000).abs();
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  Future<void> schedule(ReminderDecision decision, DateTime at) async {
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

  static const int sessionOngoingId = 9999;
  static const String _sessionChannelId = 'session_ongoing';
  static const String _sessionChannelName = 'Session Timer';
  static const String _sessionChannelDesc =
      'Shows elapsed reading time during an active session';

  Future<void> showSessionOngoing({
    required String bookTitle,
    required int currentPage,
    required int totalPages,
    required int elapsedSeconds,
    required String? payload,
    bool isPaused = false,
  }) async {
    try {
      final minutes = elapsedSeconds ~/ 60;
      final seconds = elapsedSeconds % 60;
      final timeStr =
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

      final progress = totalPages > 0
          ? 'p.$currentPage of $totalPages'
          : 'p.$currentPage';

      final statusBadge = isPaused ? '⏸ Paused' : '⏺ Recording';

      final androidDetails = AndroidNotificationDetails(
        _sessionChannelId,
        _sessionChannelName,
        channelDescription: _sessionChannelDesc,
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        autoCancel: false,
        showWhen: false,
        usesChronometer: false,
        category: AndroidNotificationCategory.service,
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            'session_pause_resume',
            isPaused ? 'Resume' : 'Pause',
            showsUserInterface: false,
          ),
          const AndroidNotificationAction(
            'session_finish',
            'Finish',
            showsUserInterface: true,
          ),
        ],
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: false,
        presentBadge: false,
        presentSound: false,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _plugin.show(
        id: sessionOngoingId,
        title: bookTitle,
        body: '$timeStr • $progress • $statusBadge',
        notificationDetails: details,
        payload: payload,
      );
    } catch (_) {}
  }

  Future<void> cancelSessionOngoing() async {
    try {
      await _plugin.cancel(id: sessionOngoingId);
    } catch (_) {}
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
