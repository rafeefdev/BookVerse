import 'package:book_verse/core/models/book_model.dart';

class WeeklyBookSummary {
  final Book book;
  final int totalSessions;
  final int totalDurationSeconds;
  final int totalPages;

  const WeeklyBookSummary({
    required this.book,
    required this.totalSessions,
    required this.totalDurationSeconds,
    required this.totalPages,
  });
}
