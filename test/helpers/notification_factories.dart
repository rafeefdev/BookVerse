import 'package:book_verse/core/models/book_model.dart';
import 'package:book_verse/features/notifications/model/reminder_type.dart';
import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';
import 'package:book_verse/features/reading_tracker/model/reading_session_model.dart';

ReminderDecision createDecision({
  ReminderType type = ReminderType.resumeBook,
  String title = 'Test Book',
  String body = 'Continue from page 10.',
  String? payload = 'book-1',
}) {
  return ReminderDecision(
    type: type,
    title: title,
    body: body,
    payload: payload,
  );
}

ReadingProgressModel createProgress({
  String bookId = 'book-1',
  int currentPage = 10,
  int totalReadingTimeInSeconds = 600,
  DateTime? lastRead,
  Book? book,
  int? userPageCount,
}) {
  return ReadingProgressModel(
    bookId: bookId,
    currentPage: currentPage,
    totalReadingTimeInSeconds: totalReadingTimeInSeconds,
    lastRead: lastRead,
    book: book,
    userPageCount: userPageCount,
  );
}

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

Book createBook({
  String id = 'book-1',
  String title = 'Test Book',
  String? subTitle,
  List<String> authors = const ['Test Author'],
  String publisher = 'Test Publisher',
  String publishedDate = '2024-01-01',
  String description = 'A test book.',
  String thumbnail = '',
  bool isFavorite = false,
  int pageCount = 200,
  List<String>? categories,
}) {
  return Book(
    id: id,
    title: title,
    subTitle: subTitle,
    authors: authors,
    publisher: publisher,
    publishedDate: publishedDate,
    description: description,
    thumbnail: thumbnail,
    isFavorite: isFavorite,
    pageCount: pageCount,
    categories: categories,
  );
}
