import 'package:book_verse/core/theme/themes_extension.dart';
import 'package:book_verse/features/notifications/service/notification_service.dart';
import 'package:book_verse/features/settings/model/reminder_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ReminderSection extends StatefulWidget {
  const ReminderSection({super.key});

  @override
  State<ReminderSection> createState() => _ReminderSectionState();
}

class _ReminderSectionState extends State<ReminderSection> {
  ReminderSettings _settings = ReminderSettings.defaults();
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await ReminderSettings.load();
    if (mounted) {
      setState(() {
        _settings = s;
        _loaded = true;
      });
    }
  }

  Future<void> _save(ReminderSettings s) async {
    await s.save();
    if (mounted) setState(() => _settings = s);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _settings.hour, minute: _settings.minute),
    );
    if (picked != null) {
      await _save(_settings.copyWith(hour: picked.hour, minute: picked.minute));
    }
  }

  Future<void> _pickQuietStart() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: _settings.quietStartHour,
        minute: _settings.quietStartMinute,
      ),
    );
    if (picked != null) {
      await _save(
        _settings.copyWith(
          quietStartHour: picked.hour,
          quietStartMinute: picked.minute,
        ),
      );
    }
  }

  Future<void> _pickQuietEnd() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: _settings.quietEndHour,
        minute: _settings.quietEndMinute,
      ),
    );
    if (picked != null) {
      await _save(
        _settings.copyWith(
          quietEndHour: picked.hour,
          quietEndMinute: picked.minute,
        ),
      );
    }
  }

  Future<void> _testNotification() async {
    try {
      final service = NotificationService(
        FlutterLocalNotificationsPlugin(),
      );
      await service.initialize(requestPermissions: true);
      await service.show(
        title: 'Test Notification',
        body: 'Reading reminders are working!',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test notification sent!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send notification: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox.shrink();

    final cs = context.colorScheme;
    final textTheme = context.textTheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Row(
            children: [
              Icon(Icons.notifications_outlined, size: 20, color: cs.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reading Reminders',
                      style: textTheme.titleSmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Configure notification schedule',
                      style: textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Enable Reminders'),
                    value: _settings.enabled,
                    onChanged: (v) => _save(_settings.copyWith(enabled: v)),
                  ),
                  if (_settings.enabled) ...[
                    const SizedBox(height: 8),
                    _timeTile(
                      'Reminder Time',
                      _settings.timeLabel,
                      cs,
                      textTheme,
                      onTap: _pickTime,
                    ),
                    const SizedBox(height: 4),
                    _timeTile(
                      'Quiet Hours Start',
                      _settings.quietStartLabel,
                      cs,
                      textTheme,
                      onTap: _pickQuietStart,
                    ),
                    const SizedBox(height: 4),
                    _timeTile(
                      'Quiet Hours End',
                      _settings.quietEndLabel,
                      cs,
                      textTheme,
                      onTap: _pickQuietEnd,
                    ),
                    const SizedBox(height: 16),
                    Text('Remind me about:', style: textTheme.titleSmall),
                    const SizedBox(height: 4),
                    _typeToggle(
                      'Resume Reading',
                      'For active readers',
                      _settings.typeResumeBook,
                      cs,
                      (v) => _save(_settings.copyWith(typeResumeBook: v)),
                    ),
                    _typeToggle(
                      'Streak Protection',
                      'When streak is at risk (1-2 days)',
                      _settings.typeStreakProtection,
                      cs,
                      (v) => _save(_settings.copyWith(typeStreakProtection: v)),
                    ),
                    _typeToggle(
                      'Re-engagement',
                      'When inactive',
                      _settings.typeReengagement,
                      cs,
                      (v) => _save(_settings.copyWith(typeReengagement: v)),
                    ),
                    _typeToggle(
                      'Daily Goal',
                      'When behind target',
                      _settings.typeGoal,
                      cs,
                      (v) => _save(_settings.copyWith(typeGoal: v)),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    Text(
                      'Next reminder: Today at ${_settings.timeLabel}',
                      style: textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _testNotification,
                        icon: const Icon(Icons.notifications_active, size: 18),
                        label: const Text('Send Test Notification'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }

  Widget _timeTile(
    String label,
    String value,
    ColorScheme cs,
    TextTheme textTheme, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: textTheme.bodyMedium),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, size: 18, color: cs.onSurfaceVariant),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeToggle(
    String label,
    String subtitle,
    bool value,
    ColorScheme cs,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(label, style: Theme.of(context).textTheme.bodySmall),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}
