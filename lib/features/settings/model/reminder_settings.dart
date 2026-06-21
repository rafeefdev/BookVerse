import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const _reminderSettingsKey = 'reminder_settings';

class ReminderSettings {
  final bool enabled;
  final int hour;
  final int minute;
  final int quietStartHour;
  final int quietStartMinute;
  final int quietEndHour;
  final int quietEndMinute;
  final bool typeResumeBook;
  final bool typeStreakProtection;
  final bool typeReengagement;
  final bool typeGoal;

  const ReminderSettings({
    this.enabled = true,
    this.hour = 19,
    this.minute = 0,
    this.quietStartHour = 22,
    this.quietStartMinute = 0,
    this.quietEndHour = 7,
    this.quietEndMinute = 0,
    this.typeResumeBook = true,
    this.typeStreakProtection = true,
    this.typeReengagement = true,
    this.typeGoal = true,
  });

  factory ReminderSettings.defaults() => const ReminderSettings();

  String get timeLabel {
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final amPm = hour >= 12 ? 'PM' : 'AM';
    return '${h.toString().padLeft(2, ' ')}:${minute.toString().padLeft(2, '0')} $amPm';
  }

  String get quietStartLabel {
    final h = quietStartHour > 12
        ? quietStartHour - 12
        : (quietStartHour == 0 ? 12 : quietStartHour);
    final amPm = quietStartHour >= 12 ? 'PM' : 'AM';
    return '${h.toString().padLeft(2, ' ')}:${quietStartMinute.toString().padLeft(2, '0')} $amPm';
  }

  String get quietEndLabel {
    final h = quietEndHour > 12
        ? quietEndHour - 12
        : (quietEndHour == 0 ? 12 : quietEndHour);
    final amPm = quietEndHour >= 12 ? 'PM' : 'AM';
    return '${h.toString().padLeft(2, ' ')}:${quietEndMinute.toString().padLeft(2, '0')} $amPm';
  }

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'hour': hour,
        'minute': minute,
        'quietStartHour': quietStartHour,
        'quietStartMinute': quietStartMinute,
        'quietEndHour': quietEndHour,
        'quietEndMinute': quietEndMinute,
        'typeResumeBook': typeResumeBook,
        'typeStreakProtection': typeStreakProtection,
        'typeReengagement': typeReengagement,
        'typeGoal': typeGoal,
      };

  factory ReminderSettings.fromJson(Map<String, dynamic> json) =>
      ReminderSettings(
        enabled: json['enabled'] as bool? ?? true,
        hour: json['hour'] as int? ?? 19,
        minute: json['minute'] as int? ?? 0,
        quietStartHour: json['quietStartHour'] as int? ?? 22,
        quietStartMinute: json['quietStartMinute'] as int? ?? 0,
        quietEndHour: json['quietEndHour'] as int? ?? 7,
        quietEndMinute: json['quietEndMinute'] as int? ?? 0,
        typeResumeBook: json['typeResumeBook'] as bool? ?? true,
        typeStreakProtection: json['typeStreakProtection'] as bool? ?? true,
        typeReengagement: json['typeReengagement'] as bool? ?? true,
        typeGoal: json['typeGoal'] as bool? ?? true,
      );

  static Future<ReminderSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_reminderSettingsKey);
    if (raw == null) return ReminderSettings.defaults();
    try {
      return ReminderSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return ReminderSettings.defaults();
    }
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_reminderSettingsKey, jsonEncode(toJson()));
  }

  ReminderSettings copyWith({
    bool? enabled,
    int? hour,
    int? minute,
    int? quietStartHour,
    int? quietStartMinute,
    int? quietEndHour,
    int? quietEndMinute,
    bool? typeResumeBook,
    bool? typeStreakProtection,
    bool? typeReengagement,
    bool? typeGoal,
  }) {
    return ReminderSettings(
      enabled: enabled ?? this.enabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      quietStartHour: quietStartHour ?? this.quietStartHour,
      quietStartMinute: quietStartMinute ?? this.quietStartMinute,
      quietEndHour: quietEndHour ?? this.quietEndHour,
      quietEndMinute: quietEndMinute ?? this.quietEndMinute,
      typeResumeBook: typeResumeBook ?? this.typeResumeBook,
      typeStreakProtection: typeStreakProtection ?? this.typeStreakProtection,
      typeReengagement: typeReengagement ?? this.typeReengagement,
      typeGoal: typeGoal ?? this.typeGoal,
    );
  }
}
