import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';

class FinishedBookInfo {
  final ReadingProgressModel progress;
  final String? formattedCompletionDate;
  final String? formattedDaysSpent;
  final String formattedTotalTime;
  final int totalSessions;

  const FinishedBookInfo({
    required this.progress,
    this.formattedCompletionDate,
    this.formattedDaysSpent,
    required this.formattedTotalTime,
    this.totalSessions = 0,
  });
}
