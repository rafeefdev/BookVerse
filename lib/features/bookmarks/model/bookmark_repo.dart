import 'dart:developer';
import 'package:book_verse/core/models/book_model.dart';
import 'package:book_verse/features/bookmarks/data/bookmark_datasource.dart';
import 'package:book_verse/features/reading_tracker/data/reading_tracker_datasource.dart';
import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';

class BookmarkRepo {
  final BookmarkDatasource _bookmarkDatasource;
  final ReadingTrackerDatasource _readingTrackerDatasource;

  BookmarkRepo({
    required BookmarkDatasource bookmarkDatasource,
    required ReadingTrackerDatasource readingTrackerDatasource,
  })  : _bookmarkDatasource = bookmarkDatasource,
        _readingTrackerDatasource = readingTrackerDatasource;

  Future<List<ReadingProgressModel>> getReadingProgressWithBooks() async {
    try {
      final booksMap = await _bookmarkDatasource.getBookmarkedBooks();
      final progressMap =
          await _readingTrackerDatasource.getAllReadingProgress();

      final List<Book> books = booksMap.map((b) => Book.fromJson(b)).toList();
      final bookIds = books.map((b) => b.id).toSet();
      return progressMap
          .where((progress) => bookIds.contains(progress.bookId))
          .map((progress) {
            final book = books.firstWhere((b) => b.id == progress.bookId);
            return progress.copyWith(book: book);
          })
          .toList();
    } catch (e, stack) {
      log('getReadingProgressWithBooks error: $e\n$stack');
      return [];
    }
  }

  Future<void> addToBookmark(Book book) async {
    try {
      await _bookmarkDatasource.addToBookmark(book.toMap());
      final initialProgress = ReadingProgressModel(
        bookId: book.id,
        currentPage: 0,
      );
      await _readingTrackerDatasource.saveReadingProgress(initialProgress);
    } catch (e, stack) {
      log('addToBookmark error: $e\n$stack');
    }
  }

  Future<void> removeBookmark(String bookId) async {
    try {
      await _bookmarkDatasource.removeBookmark(bookId);
      await _readingTrackerDatasource.deleteReadingProgress(bookId);
      await _readingTrackerDatasource.deleteReadingSessions(bookId);
    } catch (e, stack) {
      log('removeBookmark error: $e\n$stack');
    }
  }

  Future<bool> isBookmarked(String id) async {
    try {
      final progress =
          await _readingTrackerDatasource.getReadingProgress(id);
      return progress != null;
    } catch (e, stack) {
      log('isBookmarked error: $e\n$stack');
      return false;
    }
  }
}
