import 'package:book_verse/core/models/book_model.dart';
import 'package:book_verse/features/bookmarks/data/bookmark_datasource.dart';
import 'package:book_verse/features/reading_tracker/data/reading_tracker_datasource.dart';
import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';

Future<void> removeBookmarkCascade({
  required BookmarkDatasource bookmarkDatasource,
  required ReadingTrackerDatasource readingTrackerDatasource,
  required String bookId,
}) async {
  await bookmarkDatasource.removeBookmark(bookId);
  await readingTrackerDatasource.deleteReadingProgress(bookId);
  await readingTrackerDatasource.deleteReadingSessions(bookId);
}

Future<void> addBookmarkWithProgress({
  required BookmarkDatasource bookmarkDatasource,
  required ReadingTrackerDatasource readingTrackerDatasource,
  required Book book,
}) async {
  await bookmarkDatasource.addToBookmark(book.toMap());
  final initialProgress = ReadingProgressModel(
    bookId: book.id,
    currentPage: 0,
  );
  await readingTrackerDatasource.saveReadingProgress(initialProgress);
}
