import 'package:book_verse/features/dashboard/model/dashboard_state.dart';

class WeeklyReportState {
  final List<DailyReadingMinutes> weeklyReading;
  final int totalPages;
  final int totalMinutes;
  final int totalSessions;
  final int activeDays;
  final DateTime weekStart;
  final DateTime weekEnd;

  const WeeklyReportState({
    required this.weeklyReading,
    required this.totalPages,
    required this.totalMinutes,
    required this.totalSessions,
    required this.activeDays,
    required this.weekStart,
    required this.weekEnd,
  });
}
