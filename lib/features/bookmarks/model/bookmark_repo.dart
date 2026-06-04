import 'dart:developer';
import 'package:book_verse/core/models/book_model.dart';
import 'package:book_verse/core/services/sqflite_service.dart';
import 'package:book_verse/features/bookmarks/model/local_bookmark_service.dart';
import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';

class BookmarkRepo {
  final LocalBookmarkService localBookmarkService;
  final SqfliteService _sqfliteService = SqfliteService.instance;

  BookmarkRepo({required this.localBookmarkService});

  Future<List<ReadingProgressModel>> getReadingProgressWithBooks() async {
    try {
      final booksMap = await localBookmarkService.getBookmarkedBooks();
      final progressMap = await _sqfliteService.getAllReadingProgress();

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
      await localBookmarkService.addToBookmark(book.toMap());
      final initialProgress = ReadingProgressModel(
        bookId: book.id,
        currentPage: 0,
      );
      await _sqfliteService.saveReadingProgress(initialProgress);
    } catch (e, stack) {
      log('addToBookmark error: $e\n$stack');
    }
  }

  Future<void> removeBookmark(String bookId) async {
    try {
      await localBookmarkService.removeBookmark(bookId);
      await _sqfliteService.deleteReadingProgress(bookId);
      await _sqfliteService.deleteReadingSessions(bookId);
    } catch (e, stack) {
      log('removeBookmark error: $e\n$stack');
    }
  }

  Future<bool> isBookmarked(String id) async {
    try {
      final progress = await _sqfliteService.getReadingProgress(id);
      return progress != null;
    } catch (e, stack) {
      log('isBookmarked error: $e\n$stack');
      return false;
    }
  }
}
