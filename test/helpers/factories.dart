import 'package:book_verse/features/reading_tracker/model/reading_session_model.dart';

ReadingSessionModel createSession({
  required String bookId,
  required DateTime timestamp,
  int durationInSeconds = 600,
  int endPage = 30,
  int? startPage,
}) {
  return ReadingSessionModel(
    bookId: bookId,
    durationInSeconds: durationInSeconds,
    endPage: endPage,
    timestamp: timestamp,
    startPage: startPage,
  );
}
