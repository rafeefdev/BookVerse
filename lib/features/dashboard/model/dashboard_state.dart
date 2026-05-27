import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';

class DashboardState {
  final int todayMinutes;
  final int todayPages;
  final int yesterdayMinutes;
  final int streak;
  final List<DailyReadingMinutes> weeklyReading;
  final List<ReadingProgressModel> currentlyReading;

  DashboardState({
    required this.todayMinutes,
    required this.todayPages,
    required this.yesterdayMinutes,
    required this.streak,
    required this.weeklyReading,
    required this.currentlyReading,
  });
}

class DailyReadingMinutes {
  final String label;
  final int minutes;
  final int pages;
  final bool isToday;

  DailyReadingMinutes({
    required this.label,
    required this.minutes,
    required this.pages,
    required this.isToday,
  });
}
