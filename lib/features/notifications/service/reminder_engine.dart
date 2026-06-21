import 'package:book_verse/features/notifications/model/reminder_type.dart';
import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';
import 'package:book_verse/features/reading_tracker/model/reading_session_model.dart';

class ReminderEngine {
  const ReminderEngine();

  ReminderDecision? decide({
    required List<ReadingSessionModel> allSessions,
    required List<ReadingProgressModel> currentlyReading,
    required DateTime now,
    required int streak,
    required DateTime? lastNotificationDate,
  }) {
    final todayStart = DateTime(now.year, now.month, now.day);

    // --- cooldown check ---
    if (lastNotificationDate != null) {
      final hoursSince =
          now.difference(lastNotificationDate).inHours;
      if (hoursSince < 4) return null;
    }

    final hasReadToday = allSessions.any(
      (s) => !s.timestamp.isBefore(todayStart),
    );

    // If user already read today, no notification needed
    if (hasReadToday) return null;

    // --- priority 1: streak protection (at risk: 1-2 days) ---
    if (streak >= 1 && streak < 3) {
      return _buildStreakProtection(streak, currentlyReading);
    }

    // --- priority 2: broken streak (had streak, lost it) ---
    final hasEverRead = allSessions.isNotEmpty;
    if (streak == 0 && hasEverRead) {
      final daysSinceLastRead = _daysSinceLastSession(allSessions, now);
      return _buildReengagement(daysSinceLastRead, currentlyReading);
    }

    // --- priority 3: resume book (active user, streak >= 3) ---
    if (streak >= 3) {
      return _buildResumeBook(currentlyReading);
    }

    // --- fallback: new user, no history ---
    if (currentlyReading.isNotEmpty) {
      return _buildResumeBook(currentlyReading);
    }

    return null;
  }

  ReminderDecision _buildStreakProtection(
    int streak,
    List<ReadingProgressModel> currentlyReading,
  ) {
    if (currentlyReading.isNotEmpty) {
      final book = currentlyReading.first.book;
      final bookName = book?.title ?? 'your book';
      return ReminderDecision(
        type: ReminderType.streakProtection,
        title: '🔥 $streak-day streak',
        body:
            'Read 5 more minutes today to keep your streak alive. $bookName is waiting.',
        payload: currentlyReading.first.bookId,
      );
    }

    return ReminderDecision(
      type: ReminderType.streakProtection,
      title: '🔥 $streak-day streak',
      body: 'Read just 5 minutes today to keep your streak alive.',
    );
  }

  ReminderDecision _buildReengagement(
    int daysSinceLastRead,
    List<ReadingProgressModel> currentlyReading,
  ) {
    if (daysSinceLastRead == 1) {
      // day 1: soft emotional
      if (currentlyReading.isNotEmpty) {
        final book = currentlyReading.first.book;
        return ReminderDecision(
          type: ReminderType.reengagement,
          title: 'Your book is waiting 📖',
          body:
              'We miss your reading sessions. ${book?.title ?? 'Your book'} is ready when you are.',
          payload: currentlyReading.first.bookId,
        );
      }
      return ReminderDecision(
        type: ReminderType.reengagement,
        title: 'Your books miss you 📖',
        body: 'We miss your reading sessions. Just 5 minutes today.',
      );
    }

    if (daysSinceLastRead <= 3) {
      // day 2-3: low barrier
      if (currentlyReading.isNotEmpty) {
        final book = currentlyReading.first.book;
        return ReminderDecision(
          type: ReminderType.reengagement,
          title: 'Just 5 minutes today',
          body:
              'No pressure. Just 5 minutes with ${book?.title ?? 'your book'} today.',
          payload: currentlyReading.first.bookId,
        );
      }
      return ReminderDecision(
        type: ReminderType.reengagement,
        title: 'Just 5 minutes today',
        body: 'No pressure. Just 5 minutes of reading today.',
      );
    }

    if (daysSinceLastRead <= 7) {
      // day 4-7: one page
      return ReminderDecision(
        type: ReminderType.reengagement,
        title: 'Start with 1 page',
        body:
            'No target. No pressure. Just open a book and read 1 page. That\'s it.',
      );
    }

    // day 8+: once per week max (handled by caller via notificationDate check)
    return ReminderDecision(
      type: ReminderType.reengagement,
      title: 'Still time to read',
      body:
          'One page is all it takes. Open any book and start — the hardest part is the first page.',
    );
  }

  ReminderDecision _buildResumeBook(
    List<ReadingProgressModel> currentlyReading,
  ) {
    if (currentlyReading.isEmpty) {
      return ReminderDecision(
        type: ReminderType.resumeBook,
        title: 'Time to read 📖',
        body: 'Open any book and enjoy a few pages today.',
      );
    }

    final book = currentlyReading.first.book;
    final progress = currentlyReading.first;
    final bookName = book?.title ?? 'your book';
    final page = progress.currentPage;

    return ReminderDecision(
      type: ReminderType.resumeBook,
      title: bookName,
      body: 'Continue from page $page.',
      payload: currentlyReading.first.bookId,
    );
  }

  int _daysSinceLastSession(
    List<ReadingSessionModel> sessions,
    DateTime now,
  ) {
    if (sessions.isEmpty) return 999;
    sessions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return now.difference(sessions.first.timestamp).inDays;
  }

  DateTime bestTime({
    required DateTime now,
    required int streak,
    required DateTime? lastNotificationDate,
  }) {
    // hardcoded quiet hours: 22:00 - 07:00
    const quietStart = 22;
    const quietEnd = 7;

    int defaultHour;
    if (streak >= 3) {
      defaultHour = 20; // active users: later
    } else if (streak >= 1) {
      defaultHour = 19; // at-risk: earlier
    } else {
      defaultHour = 18; // inactive: early evening
    }

    final scheduled =
        DateTime(now.year, now.month, now.day, defaultHour);

    // If scheduled time is in the past, schedule for tomorrow
    if (scheduled.isBefore(now)) {
      return scheduled.add(const Duration(days: 1));
    }

    // If within quiet hours, move to quietEnd
    if (defaultHour >= quietStart || defaultHour < quietEnd) {
      return DateTime(now.year, now.month, now.day, quietEnd);
    }

    // ensure quiet hours: if scheduled after 22:00, move to next day 07:00
    if (defaultHour >= quietStart) {
      return DateTime(now.year, now.month, now.day + 1, quietEnd);
    }

    return scheduled;
  }

  bool shouldScheduleToday({
    required DateTime now,
    required DateTime? lastNotificationDate,
  }) {
    // max 1 notification per day
    if (lastNotificationDate == null) return true;
    final todayStart = DateTime(now.year, now.month, now.day);
    return lastNotificationDate.isBefore(todayStart);
  }
}
