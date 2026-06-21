enum ReminderType { resumeBook, streakProtection, reengagement, goalReminder }

class ReminderDecision {
  final ReminderType type;
  final String title;
  final String body;
  final String? payload;

  const ReminderDecision({
    required this.type,
    required this.title,
    required this.body,
    this.payload,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderDecision &&
          type == other.type &&
          title == other.title &&
          body == other.body &&
          payload == other.payload;

  @override
  int get hashCode => Object.hash(type, title, body, payload);
}
