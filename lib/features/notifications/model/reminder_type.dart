enum ReminderType { resumeBook, streakProtection, reengagement }

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
}
